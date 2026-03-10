import type { OpenAPIHono } from "@hono/zod-openapi";
import type { Env } from "hono";
import {
  handler as postCommentHandler,
  route as postCommentRoute,
} from "./routes/comment.post";
import {
  handler as getCommentHandler,
  route as getCommentRoute,
} from "./routes/comment.get"
import {
  handler as deleteCommentHandler,
  route as deleteCommentRoute,
} from "./routes/comment.delete"
import {
  handler as patchCommentHandler,
  route as pathCommentRoute,
} from "./routes/comment.patch"
import {
  handler as getIdCommentHandler,
  route as getIdCommentRoute,
} from "./routes/comment.id.get"

export default function (app: OpenAPIHono<Env>) {
  app.openapi(postCommentRoute, postCommentHandler);
  app.openapi(getCommentRoute, getCommentHandler);
  app.openapi(getIdCommentRoute, getIdCommentHandler);
  app.openapi(deleteCommentRoute, deleteCommentHandler);
  app.openapi(pathCommentRoute, patchCommentHandler);

}
