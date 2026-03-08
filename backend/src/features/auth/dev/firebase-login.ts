import { Hono } from "hono";
import { z } from "zod";
import { setCookie } from "hono/cookie";
import { sign } from "hono/jwt";
import { createSession } from "../session";
import type { SessionStore } from "../session.store";
import { getDatabase } from "firebase-admin/database";

const BodySchema = z.object({
  userId: z.string().min(1),
});

export function devAuthRouter(store: SessionStore) {
  const app = new Hono();

  app.post("/login", async (c) => {
    if ((process.env.ENVIRONMENT ?? "development") === "production") {
      console.warn("[dev-auth] Login attempt blocked: Production environment detected");
      return c.json({ error: "Not available in production" }, 404);
    }

    const parsed = BodySchema.safeParse(await c.req.json().catch(() => null));
    if (!parsed.success) {
      console.error("[dev-auth] Login failed: Invalid body schema", parsed.error.format());
      return c.json(
        { error: "Invalid body. Expected { userId: string }" },
        400,
      );
    }

    const userId = parsed.data.userId;
    console.log(`[dev-auth] Attempting login for userId: ${userId}`);

    const db = getDatabase();
    const profileRef = db.ref("profiles").child(userId);
    const snap = await profileRef.get();

    if (!snap.exists()) {
      console.log(`[dev-auth] Profile not found, seeding new dev user: ${userId}`);
      const newProfile = {
        id: userId,
        email: `${userId}@dev.local`,
        username: userId,
        firstName: "Dev",
        lastName: "User",
        description: "Seeded by dev login",
        birthDate: null,
        profilePicture: null,
        creationDate: Date.now(),
        lastLoginDate: Date.now(),
      };
      console.log("[dev-auth] Creating new profile object:", newProfile);
      await profileRef.set(newProfile);
    } else {
      console.log(`[dev-auth] Profile exists for: ${userId}, updating lastLoginDate`);
      const updateData = {
        lastLoginDate: Date.now(),
      };
      console.log("[dev-auth] Creating update object:", updateData);
      await profileRef.update(updateData);
    }

    const expirationMs = Number(
      process.env.AUTH_SESSION_EXPIRATION_MS ?? "86400000",
    );
    const expiresAt = new Date(Date.now() + expirationMs);
    const session = await createSession(store, userId, expiresAt);

    console.log("[dev-auth] Session object created via createSession:", session);

    const secret = process.env.AUTH_SECRET;
    if (!secret) throw new Error("Missing AUTH_SECRET");

    const jwt = await sign({ sessionId: session.id }, secret);

    console.log(`[dev-auth] Session created: ${session.id}, expires at: ${expiresAt.toISOString()}`);
    const env = process.env.ENVIRONMENT ?? "development";
    const cookieName = "session";
    setCookie(c, cookieName, jwt, {
      path: "/",
      httpOnly: true,
      secure: false,
      sameSite: env === "production" ? "None" : "Lax",
      expires: expiresAt,
    });

    console.log(`[dev-auth] Login successful for ${userId}. Cookie set.`);
    return c.json({ ok: true, userId, sessionId: session.id });
  });

  return app;
}
