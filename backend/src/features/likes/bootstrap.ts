import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import {
  handler as postLikeHandler,
  route as postLikeRoute,
} from "./routes/like.post";
import {
  handler as deleteLikeHandler,
  route as deleteLikeRoute,
} from "./routes/like.delete";

export default function (app: OpenAPIHono<Env>) {
  app.openapi(postLikeRoute, postLikeHandler);
  app.openapi(deleteLikeRoute, deleteLikeHandler);
}
