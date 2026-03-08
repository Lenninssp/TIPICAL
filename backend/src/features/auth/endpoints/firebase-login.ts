import z from "zod";
import type { SessionStore } from "../session.store";
import { Hono } from "hono";
import { getFirebaseAuth } from "../../shared/lib/firebase-admin";
import { createSession } from "../session";
import { sign } from "hono/jwt";
import { deleteCookie, setCookie } from "hono/cookie";
import { getDatabase } from "firebase-admin/database";

const BodySchema = z.object({
  idToken: z.string().min(1)
})

export function firebaseAuthRouter(store: SessionStore) {
  const app = new Hono();

  // todo: bring this implementation up to standard of the other endpoints, but little by little
  app.post("/login", async (c) => {
    const parsed = BodySchema.safeParse(await c.req.json().catch(() => null));
    if (!parsed.success) {
      return c.json({ error: "Invalid bodyLimit, Expected { idToken: string}"}, 400);
    }

    const { idToken } = parsed.data;

    const auth = getFirebaseAuth();
    let decoded;
    try {
      decoded = await auth.verifyIdToken(idToken, true)
    } catch {
      return c.json({ error: "Invalid Firebase token" }, 401);
    }

     const userId = decoded.uid;
    const email = decoded.email ?? null;
    const profilePicture = decoded.picture ?? null;
    const username =
      decoded.name ??
      (email ? email.split("@")[0] : "user");

    const db = getDatabase();
    const profileRef = db.ref("profiles").child(userId);
    const profileSnap = await profileRef.get();

    const now = Date.now();

    if (profileSnap.exists()) {
      const existingProfile = profileSnap.val();

      await profileRef.update({
        id: userId,
        email,
        username,
        profilePicture,
        lastLoginDate: now,
        firstName: existingProfile.firstName ?? "",
        lastName: existingProfile.lastName ?? "",
        description: existingProfile.description ?? "",
        birthDate: existingProfile.birthDate ?? null,
        creationDate: existingProfile.creationDate ?? now,
      });
    } else {
      await profileRef.set({
        id: userId,
        email,
        username,
        firstName: "",
        lastName: "",
        description: "",
        birthDate: null,
        profilePicture,
        creationDate: now,
        lastLoginDate: now,
      });
    }

    const expirationMs = Number(process.env.AUTH_SESSION_EXPIRATION_MS ?? "86400000");
    const expiresAt = new Date(Date.now() + expirationMs);
    const session = await createSession(store, userId, expiresAt);

    const secret = process.env.AUTH_SECRET;
    if (!secret) throw new Error("Missing AUTH_SECRET");

    const jwt = await sign({ sessionId: session.id }, secret);

    const env = process.env.ENVIRONMENT ?? "development";
    const cookieName = process.env.AUTH_COOKIE_NAME ?? (env === "production" ? "__Secure-session" : "session");
    
    setCookie(c, cookieName, jwt, {
      path: "/",
      httpOnly: true,
      secure: env === "production",
      sameSite: "Lax",
      expires: expiresAt,
    })

    return c.json({ ok: true });
  });

  app.post("/logout", async(c) => {
    const env = process.env.ENVIRONMENT ?? "development";
    const cookieName = 
      process.env.AUTH_COOKIE_NAME ??
      (env === "production" ? "__Secure_session" : "session");

      deleteCookie(c, cookieName, { path: "/"});

      return c.json({ ok: true });
  })

  return app;
}