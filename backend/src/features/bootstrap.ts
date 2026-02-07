import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import postsBootstrap from './posts/bootstrap'

export const bootstrapFeature = (app: OpenAPIHono<Env>) => {
  postsBootstrap(app);
}