import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";

export default function (app: OpenAPIHono<Env>) {
  app.get('/auth/signin');
  app.get('/auth/login');

  app.get('/auth/signout');
}