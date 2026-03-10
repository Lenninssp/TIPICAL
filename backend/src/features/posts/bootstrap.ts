import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import {handler as postPostHandler, route as postPostRoute } from './routes/POST/route'
import {handler as getPostListHandler, route as getPostListRoute} from './routes/list/GET/route'
import {handler as patchPostHandler, route as patchPostRoute} from './routes/PATCH/route'
import {handler as deletePostHandler, route as deletepostRoute} from './routes/DELETE/route'

export default function (app: OpenAPIHono<Env>) {
  app.openapi(postPostRoute, postPostHandler);
  app.openapi(getPostListRoute, getPostListHandler);
  app.openapi(patchPostRoute, patchPostHandler);
  app.openapi(deletepostRoute, deletePostHandler)
}