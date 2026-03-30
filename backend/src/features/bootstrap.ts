import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import postsBootstrap from './posts/bootstrap'
import userBootstrap from './user/bootstrap'
import commentsBootstrap from "./comments/bootstrap"
import likesBootstrap from "./likes/bootstrap"

export const bootstrapFeatures = (app: OpenAPIHono<Env>) => {
  postsBootstrap(app);
  userBootstrap(app);
  commentsBootstrap(app);
  likesBootstrap(app);
}