export type Session = {
  id: string;
  userId: string;
  createdAt: Date;
  updatedAT: Date;
  expiresAt: Date;
};

export interface SessionStore {
  put(key: string, value: string, opts: { expiration: number}): Promise<void>;
  get(key: string): Promise<string|null>
  delete(key: string): Promise<void>;
}


export class MemorySessionStore implements SessionStore {
  private map = new Map<string, { value: string; expiresAtMs: number}>();
  async put(key: string, value: string, opts: { expiration: number}) {
    this.map.set(key, { value, expiresAtMs: opts.expiration * 1000 });
  }

  async get (key: string) {
    const entry  = this.map.get(key);
    if (!entry) return null;
    if (Date.now() > entry.expiresAtMs) {
      this.map.delete(key);
      return null;
    }
    return entry.value;
  }

  async delete(key: string) {
    this.map.delete(key)
  }
}




// todo: search what is a KV store, in-memory store, Redis/Cloudflare KV.