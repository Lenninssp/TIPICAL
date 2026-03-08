import { Hono } from "hono";
import { z } from "zod";
import { sign } from "hono/jwt";
import { getDatabase } from "firebase-admin/database";

const BodySchema = z.object({
  userId: z.string().min(1),
});

export function devAuthRouter() {
  const app = new Hono();

  app.post("/login", async (c) => {
    const parsed = BodySchema.safeParse(await c.req.json().catch(() => null));
    if (!parsed.success) {
      return c.json(
        { error: "Invalid body. Expected { userId: string }" },
        400,
      );
    }

    const userId = parsed.data.userId;
    const db = getDatabase();
    const profileRef = db.ref("profiles").child(userId);
    const snap = await profileRef.get();

    if (!snap.exists()) {
      await profileRef.set({
        id: userId,
        email: `${userId}@dev.local`,
        username: userId,
        firstName: "Dev",
        lastName: "User",
        description: "Seeded by dev bearer login",
        birthDate: null,
        profilePicture: null,
        creationDate: Date.now(),
        lastLoginDate: Date.now(),
      });
    } else {
      await profileRef.update({
        lastLoginDate: Date.now(),
      });
    }

    const secret = process.env.AUTH_SECRET;
    if (!secret) throw new Error("Missing AUTH_SECRET");

    const expirationMs = Number(
      process.env.AUTH_SESSION_EXPIRATION_MS ?? "86400000",
    );
    const expiresAtUnix = Math.floor((Date.now() + expirationMs) / 1000);

    const token = await sign(
      {
        sub: userId,
        userId,
        type: "dev",
        exp: expiresAtUnix,
      },
      secret,
    );

    return c.json({
      ok: true,
      userId,
      token,
      tokenType: "Bearer",
    });
  });

  return app;
}