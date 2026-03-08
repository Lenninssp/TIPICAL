import z from "zod";
import { CommentSchema, CreateCommentSchema } from "../models/comment.schema";
import { createSuccessResponseSchema } from "../../shared/responses/successResponse";
import { createRoute } from "@hono/zod-openapi";
import { InvalidInputResponseSchema } from "../../shared/responses/invalidInputResponse";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../shared/responses/unauthorizedResponse";
import { notFoundResponse, NotFoundResponseSchema } from "../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getCurrentUserId } from "../../auth/current-user";
import { getDatabase } from "firebase-admin/database";

const entityType = "comments";

interface RequestValidationTargets {
  out: {
    json: z.infer<typeof CreateCommentSchema>;
  }
}

const ResponseSchema = createSuccessResponseSchema(entityType, CommentSchema);

export const route = createRoute({
  method: "post",
  path: `/${entityType}`,
  request: {
    body: {
      content: {
        "application/json": {
          schema: CreateCommentSchema,
        },
      },
      required: true,
    },
  },
  description: "Create a new comment",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The created comment",
    },
    400: {
      content: {
        "application/json": {
          schema: InvalidInputResponseSchema,
        },
      },
      description: "Bad request",
    },
    401: {
      content: {
        "application/json": {
          schema: UnauthorizedResponseSchema,
        },
      },
      description: "Unauthorized",
    },
    404: {
      content: {
        "application/json": {
          schema: NotFoundResponseSchema,
        },
      },
      description: "Post not found",
    },
  },
});

export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const body = c.req.valid("json");
  const userId = getCurrentUserId(c);

  if (!userId){
    return unauthorizedResponse(c, "No user found");
  }

  const db = getDatabase();

  const postSnap = await db.ref("posts").child(body.postId).get();
  if (!postSnap.exists()) {
    return notFoundResponse(c, "Post not found");
  }

  const commentsRef = db.ref(entityType);
  const newRef = commentsRef.push();
  const id = newRef.key;

  if (!id) {
    throw new Error("Failed to generate comment id");
  }
  const now = Date.now();

  const commentRecord = {
    id,
    postId: body.postId,
    userId,
    comment: body.comment,
    hidden: false,
    creationDate: now,
    editionDate: now,
  }

  await newRef.set(commentRecord);

  const origin = new URL(c.req.url).origin;

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes: commentRecord,
      links: {
        self: `${origin}/${entityType}/${id}`
      }
    }
  })

}
