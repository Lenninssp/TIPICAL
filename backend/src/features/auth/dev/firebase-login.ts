import { Hono } from "hono";
import { z } from "zod";
import { setCookie } from "hono/cookie";
import { sign } from "hono/jwt";
import { createSession } from "../session";
import type { SessionStore } from "../session.store";

const BodySchema = z.object({
  userId: z.string().min(1),
});

export function devAuthRouter(store: SessionStore) {
  const app = new Hono();

  app.post("/login", async (c) => {
    if ((process.env.ENVIRONMENT ?? "development") === "production") {
      return c.json({ error: "Not available in production" }, 404);
    }

    const parsed = BodySchema.safeParse(await c.req.json().catch(() => null));
    if (!parsed.success) {
      return c.json({ error: "Invalid body. Expected { userId: string }" }, 400);
    }

    const userId = parsed.data.userId;

    const expirationMs = Number(process.env.AUTH_SESSION_EXPIRATION_MS ?? "86400000");
    const expiresAt = new Date(Date.now() + expirationMs);
    const session = await createSession(store, userId, expiresAt);

    const secret = process.env.AUTH_SECRET;
    if (!secret) throw new Error("Missing AUTH_SECRET");

    const jwt = await sign({ sessionId: session.id }, secret);

    const cookieName = "session";
    setCookie(c, cookieName, jwt, {
      path: "/",
      httpOnly: true,
      secure: false,
      sameSite: "Lax",
      expires: expiresAt,
    });

    return c.json({ ok: true, userId, sessionId: session.id });
  });

  return app;
}