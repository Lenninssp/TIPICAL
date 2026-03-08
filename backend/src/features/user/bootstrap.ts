import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import {handler as getUserHandler, route as getUserRoute} from './routes/user.get'

export default function (app: OpenAPIHono<Env>) {
  app.openapi(getUserRoute, getUserHandler);
}


