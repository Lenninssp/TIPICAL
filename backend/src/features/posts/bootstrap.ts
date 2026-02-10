import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import {handler as postPostHandler, route as postPostRoute } from './routes/POST/route'
import {handler as postListGetHandler, route as postListGetRoute} from './routes/list/GET/route'
import {handler as patchPostHandler, route as patchPostRoute} from './routes/PATCH/route'

export default function (app: OpenAPIHono<Env>) {
  app.openapi(postPostRoute, postPostHandler);
  app.openapi(postListGetRoute, postListGetHandler);
  app.openapi(patchPostRoute, patchPostHandler);
}