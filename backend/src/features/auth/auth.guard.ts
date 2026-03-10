import { getCookie } from "hono/cookie";
import { verify } from "hono/jwt";
import type { MiddlewareHandler } from "hono";
import type { SessionStore } from "./session.store";

interface AuthGuardOptions {
  excludePaths?: string[];
}

export function authGuard(
    store: SessionStore,
    options?: AuthGuardOptions,
): MiddlewareHandler {
  return async (c, next) => {
    const path = c.req.path;
    const excludePaths = options?.excludePaths ?? [];

    if (excludePaths.includes(path)) {
      console.log("[authGuard] excluded path:", path);
      return next();
    }

    const secret = process.env.AUTH_SECRET;
    if (!secret) {
      throw new Error("Missing AUTH_SECRET");
    }

    const authHeader = c.req.header("Authorization");
    console.log("[authGuard] path:", path);
    console.log("[authGuard] authorization header present:", Boolean(authHeader));

    if (authHeader?.startsWith("Bearer ")) {
      const token = authHeader.slice("Bearer ".length).trim();
      console.log("[authGuard] trying bearer token");

      try {
        const payload = await verify(token, secret);
        console.log("[authGuard] bearer payload:", payload);

        const userId =
            typeof payload.userId === "string"
                ? payload.userId
                : typeof payload.sub === "string"
                    ? payload.sub
                    : undefined;

        if (userId) {
          c.set("session", {
            id: "dev-bearer",
            userId,
            createdAt: new Date().toISOString(),
            updatedAT: new Date().toISOString(),
            expiresAt: new Date(
                ((payload.exp as number) ?? 0) * 1000,
            ).toISOString(),
          });

          console.log("[authGuard] bearer auth success for user:", userId);
          return next();
        }

        console.log("[authGuard] bearer token had no usable userId");
      } catch (err) {
        console.log("[authGuard] bearer token verify failed:", err);
      }
    }

    const env = process.env.ENVIRONMENT ?? "development";
    const cookieName =
        process.env.AUTH_COOKIE_NAME ??
        (env === "production" ? "__Secure-session" : "session");

    const sessionToken = getCookie(c, cookieName);
    console.log("[authGuard] cookie name expected:", cookieName);
    console.log("[authGuard] session cookie present:", Boolean(sessionToken));

    if (!sessionToken) {
      console.log("[authGuard] no session cookie found");
      return c.json({ error: "Unauthorized" }, 401);
    }

    try {
      const payload = await verify(sessionToken, secret);
      console.log("[authGuard] cookie payload:", payload);

      const sessionId = payload.sessionId;
      console.log("[authGuard] decoded sessionId:", sessionId);

      if (typeof sessionId !== "string") {
        console.log("[authGuard] invalid sessionId type");
        return c.json({ error: "Unauthorized" }, 401);
      }

      const session = await store.get(sessionId);
      console.log("[authGuard] store.get(sessionId):", session);

      if (!session) {
        console.log("[authGuard] session not found in store");
        return c.json({ error: "Unauthorized" }, 401);
      }

      const now = new Date();
      const expiresAt = new Date(session.expiresAt);
      console.log("[authGuard] session expiresAt:", session.expiresAt);
      console.log("[authGuard] now:", now.toISOString());

      if (expiresAt <= now) {
        console.log("[authGuard] session expired");
        return c.json({ error: "Unauthorized" }, 401);
      }

      c.set("session", session);
      console.log("[authGuard] cookie auth success for user:", session.userId);
      return next();
    } catch (err) {
      console.log("[authGuard] cookie verify failed:", err);
      return c.json({ error: "Unauthorized" }, 401);
    }
  };
}