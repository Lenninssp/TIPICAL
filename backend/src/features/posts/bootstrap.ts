import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import {handler as postPostHandler, route as postPostRoute } from './routes/POST/route'

export default function (app: OpenAPIHono<Env>) {
  app.openapi(postPostRoute, postPostHandler);
}