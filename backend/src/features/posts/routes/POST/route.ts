import type { Context, Env } from "hono";

const entityType = 'posts';

const fieldKeys = Object.keys()

export const handler = async (c: Context<Env, typeof ent)