import type { Context, MiddlewareHandler } from "hono";
import type { SessionStore } from "./session.store";
import { getCookie } from "hono/cookie";
import {verify} from "hono/jwt"
import type { JWTPayload } from "hono/utils/jwt/types";
import { deleteSession, getSessionId } from "./session";

type AuthGuardConfig = { excludePaths? : string[]};

// tiny path match helper
function isPathMatch(path: string, patterns: string[]) {
  return patterns.some((p) => p === path || (p.endsWith("*") && path.startsWith(p.slice(0, -1))));
}

export function authGuard(store: SessionStore, config?: AuthGuardConfig): MiddlewareHandler {
  const exclude = config?.excludePaths ?? [];
  return async (c: Context, next) => {
    if (isPathMatch(c.req.path, exclude)) return next();

    const env = process.env.ENVIRONMENT ?? "development";
    const cookieName = 
      process.env.AUTH_COOKIE_NAME ??
      (env === "production" ? "__Secure-session" : "session");
    
    const token = getCookie(c, cookieName);
    if(!token) return c.json({ error: "Unauthorized "}, 401);

    const secret = process.env.AUTH_SECRET;
    if(!secret) throw new Error("Missing AUTH_SECRET");

    let payload: JWTPayload;
    try {
      payload = await verify(token, secret, 'HS256');
    } catch {
      return c.json({ error: "Unauthorized" }, 401);
    }

    const sessionId = payload.sessionId ? String(payload.sessionId) : null;
    if (!sessionId) return c.json({ error: "Unauthorized" }, 401);

    const session = await getSessionId(store, sessionId);
    if (!session) return c.json({ error: "Unauthorized"}, 401);

    if (new Date(session.expiresAt).getTime() < Date.now()) {
      await deleteSession(store,sessionId);
      return c.json({ error: "Session expired" }, 401);
    }

    c.set("session", session);
    await next();
  }
}