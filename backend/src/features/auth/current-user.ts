import type { Context } from "hono";
import type { User } from "../user/models/user.type";
import { UsersTable } from "../user/models/user.table";
import { eq } from "drizzle-orm";

export function getCurrentUserId(c: Context): string | undefined {
  const session = c.get("session");
  return session?.userId;
}

export const getCurrentUser = async (c: Context): Promise<User | undefined> => {
  const session = c.get('session');
  if (!session || !session.userId) {
    return undefined;
  }
  const found = await c.get('db').select().from(UsersTable).where(eq(UsersTable.id, session.userId)).limit(1);
  return found.length ? found[0] : undefined;
};