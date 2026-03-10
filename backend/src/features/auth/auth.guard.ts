import { verify } from "hono/jwt";
import type { MiddlewareHandler } from "hono";

interface AuthGuardOptions {
  excludePaths?: string[];
}

export function authGuard(options?: AuthGuardOptions): MiddlewareHandler {
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

    const authHeader = c.req.header("Authorization");
    const bearerPrefix = "Bearer ";
    if (!authHeader || !authHeader.startsWith(bearerPrefix)) {
      c.header("WWW-Authenticate", 'Bearer realm="api"');
      return c.json({ error: "Unauthorized" }, 401);
    }

    const token = authHeader.slice(bearerPrefix.length).trim();
    if (!token) {
      c.header("WWW-Authenticate", 'Bearer realm="api"');
      return c.json({ error: "Unauthorized" }, 401);
    }

    try {
      const payload = await verify(token, secret, "HS256");
      const userId =
        typeof payload.userId === "string"
          ? payload.userId
          : typeof payload.sub === "string"
            ? payload.sub
            : undefined;

      if (!userId) {
        c.header("WWW-Authenticate", 'Bearer realm="api", error="invalid_token"');
        return c.json({ error: "Unauthorized" }, 401);
      }

      const expSeconds = typeof payload.exp === "number" ? payload.exp : undefined;
      const now = new Date();

      c.set("session", {
        id: "bearer-token",
        userId,
        createdAt: now.toISOString(),
        updatedAT: now.toISOString(),
        expiresAt: expSeconds
          ? new Date(expSeconds * 1000).toISOString()
          : new Date(now.getTime() + 60_000).toISOString(),
      });

      return next();
    } catch {
      c.header("WWW-Authenticate", 'Bearer realm="api", error="invalid_token"');
      return c.json({ error: "Unauthorized" }, 401);
    }
  };
}
