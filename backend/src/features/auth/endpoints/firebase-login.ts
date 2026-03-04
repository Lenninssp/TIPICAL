import z from "zod";
import type { SessionStore } from "../session.store";
import { Hono } from "hono";
import { getFirebaseAuth } from "../../shared/lib/firebase-admin";
import { createSession } from "../session";
import { sign } from "hono/jwt";
import { deleteCookie, setCookie } from "hono/cookie";

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

    // possible later, to add email verification to the app
    // if (!decoded.email || decoded.email_verified !== true) {
    //   return c.json({ error: "Email not verified"}, 401);
    // }

    const userId = decoded.uid;

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