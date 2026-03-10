import crypto from "node:crypto";
import type { Session, SessionStore } from "./session.store";

function randomId(bytes = 32) {
  return crypto.randomBytes(bytes).toString("hex");
}

export async function createSession(store: SessionStore, userId: string, expiresAt: Date): Promise<Session> {
  const id = randomId(32);
  const session: Session = {
    id,
    userId,
    createdAt: new Date(),
    updatedAT: new Date(),
    expiresAt
  };

  const key = `session_${id}`;
  await store.put(key, JSON.stringify(session), {
    expiration: Math.floor(expiresAt.getTime() / 1000),
  });

  return session;
}

export async function getSessionId(store: SessionStore, id: string): Promise<Session | null> {
  const key = `session_${id}`
  const data = await store.get(key);
  return data ? (JSON.parse(data) as Session) : null;
}

export async function deleteSession(store: SessionStore, id: string): Promise<void> {
  const key = `session_${id}`;
  await store.delete(key);
}