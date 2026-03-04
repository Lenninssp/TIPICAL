import type { Context } from "hono";

export function getCurrentUserId(c: Context): string | undefined {
  const session = c.get("session");
  return session?.userId;
}