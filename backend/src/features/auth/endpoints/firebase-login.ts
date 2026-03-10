import z from "zod";
import { Hono } from "hono";
import { sign } from "hono/jwt";
import { getDatabase } from "firebase-admin/database";
import { getAuth } from "firebase-admin/auth";

const BodySchema = z.object({
  idToken: z.string().min(1),
});

export function firebaseAuthRouter() {
  const app = new Hono();

  app.post("/login", async (c) => {
    const parsed = BodySchema.safeParse(await c.req.json().catch(() => null));
    if (!parsed.success) {
      return c.json({ error: "Invalid body. Expected { idToken: string }" }, 400);
    }

    const { idToken } = parsed.data;

    const auth = getAuth();
    let decoded;
    try {
      decoded = await auth.verifyIdToken(idToken, true);
    } catch {
      return c.json({ error: "Invalid Firebase token" }, 401);
    }

    const userId = decoded.uid;
    const email = decoded.email ?? null;
    const profilePicture = decoded.picture ?? null;
    const username = decoded.name ?? (email ? email.split("@")[0] : "user");

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

    const secret = process.env.AUTH_SECRET;
    if (!secret) throw new Error("Missing AUTH_SECRET");

    const expirationMs = Number(
      process.env.AUTH_TOKEN_EXPIRATION_MS ??
        process.env.AUTH_SESSION_EXPIRATION_MS ??
        "86400000",
    );
    const expiresAtUnix = Math.floor((Date.now() + expirationMs) / 1000);

    const token = await sign(
      {
        sub: userId,
        userId,
        type: "firebase",
        exp: expiresAtUnix,
      },
      secret,
    );

    return c.json({
      ok: true,
      userId,
      token,
      tokenType: "Bearer",
      expiresAt: new Date(expiresAtUnix * 1000).toISOString(),
    });
  });

  app.post("/logout", async (c) => {
    return c.json({ ok: true });
  });

  return app;
}
