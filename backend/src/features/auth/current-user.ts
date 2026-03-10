import type { Context } from "hono";
import type { User } from "../user/models/user.type";
import { getDatabase } from "firebase-admin/database";

export function getCurrentUserId(c: Context): string | undefined {
  const session = c.get("session");
  return session?.userId;
}

export const getCurrentUser = async (
  c: Context,
): Promise<User | undefined> => {
  const session = c.get("session");
  console.log("[getCurrentUser] session", session);

  if (!session || !session.userId) {
    console.log("[getCurrentUser] no session userId");
    return undefined;
  }

  const db = getDatabase();
  console.log("[getCurrentUser] reading profile for", session.userId);

  const snap = await db.ref("profiles").child(session.userId).get();
  console.log("[getCurrentUser] snap.exists()", snap.exists());

  if (!snap.exists()) {
    return undefined;
  }

  return snap.val() as User;
};