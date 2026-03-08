import type { Context, MiddlewareHandler } from "hono";
import type { SessionStore } from "./session.store";
import { getCookie } from "hono/cookie";
import {verify} from "hono/jwt"
import type { JWTPayload } from "hono/utils/jwt/types";
import { deleteSession, getSessionId } from "./session";

type AuthGuardConfig = { excludePaths? : string[]};

interface AuthGuardOptions {
  excludePaths?: string[];
}

// tiny path match helper
function isPathMatch(path: string, patterns: string[]) {
  return patterns.some((p) => p === path || (p.endsWith("*") && path.startsWith(p.slice(0, -1))));
}
export function authGuard(
  store: SessionStore,
  options?: AuthGuardOptions,
): MiddlewareHandler {
  return async (c, next) => {
    const path = c.req.path;
    const excludePaths = options?.excludePaths ?? [];

    if (excludePaths.includes(path)) {
      return next();
    }

    const secret = process.env.AUTH_SECRET;
    if (!secret) {
      throw new Error("Missing AUTH_SECRET");
    }

    // 1) Try bearer token first
    const authHeader = c.req.header("Authorization");
    if (authHeader?.startsWith("Bearer ")) {
      const token = authHeader.slice("Bearer ".length).trim();

      try {
        const payload = await verify(token, secret, "HS256");

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

          return next();
        }
      } catch (err) {
        console.warn("[authGuard] Invalid bearer token", err);
      }
    }

    // 2) Fallback to cookie session
    const env = process.env.ENVIRONMENT ?? "development";
    const cookieName =
      process.env.AUTH_COOKIE_NAME ??
      (env === "production" ? "__Secure-session" : "session");

    const sessionToken = getCookie(c, cookieName);
    if (!sessionToken) {
      return c.json({ error: "Unauthorized" }, 401);
    }

    try {
      const payload = await verify(sessionToken, secret, "HS256");
      const sessionId = payload.sessionId;

      if (typeof sessionId !== "string") {
        return c.json({ error: "Unauthorized" }, 401);
      }

      const session = await store.get(sessionId);
      if (!session) {
        return c.json({ error: "Unauthorized" }, 401);
      }

      const now = new Date();
      const expiresAt = new Date(session.expiresAt);

      if (expiresAt <= now) {
        return c.json({ error: "Unauthorized" }, 401);
      }

      c.set("session", session);
      return next();
    } catch (err) {
      console.warn("[authGuard] Invalid session cookie", err);
      return c.json({ error: "Unauthorized" }, 401);
    }
  };
}