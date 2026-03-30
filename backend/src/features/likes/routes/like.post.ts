import z from "zod";
import { LikeSchema, CreateLikeSchema } from "../models/like.schema";
import { createSuccessResponseSchema } from "../../shared/responses/successResponse";
import { createRoute } from "@hono/zod-openapi";
import { InvalidInputResponseSchema } from "../../shared/responses/invalidInputResponse";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../shared/responses/unauthorizedResponse";
import { notFoundResponse, NotFoundResponseSchema } from "../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getCurrentUserId } from "../../auth/current-user";
import { getDatabase } from "firebase-admin/database";

const entityType = "post_likes";

interface RequestValidationTargets {
  out: {
    json: z.infer<typeof CreateLikeSchema>;
  }
}

const ResponseSchema = createSuccessResponseSchema(entityType, LikeSchema);

export const route = createRoute({
  method: "post",
  path: `/${entityType}`,
  request: {
    body: {
      content: {
        "application/json": {
          schema: CreateLikeSchema,
        },
      },
      required: true,
    },
  },
  description: "Like a post",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The created like",
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

  if (!userId) {
    return unauthorizedResponse(c, "No user found");
  }

  const db = getDatabase();

  const postSnap = await db.ref("posts").child(body.postId).get();
  if (!postSnap.exists()) {
    return notFoundResponse(c, "Post not found");
  }

  const likesRef = db.ref(entityType);
  
  const allLikesSnap = await likesRef.get();
  const allLikes = (allLikesSnap.val() ?? {}) as Record<string, any>;
  
  let existingLike: any = null;
  for (const id in allLikes) {
    const val = allLikes[id];
    if (val.postId === body.postId && val.userId === userId) {
      existingLike = val;
      break;
    }
  }

  const origin = new URL(c.req.url).origin;

  if (existingLike) {
    return c.json<z.infer<typeof ResponseSchema>, 200>({
      data: {
        id: existingLike.id,
        type: entityType,
        attributes: existingLike,
        links: {
          self: `${origin}/${entityType}/${existingLike.id}`
        }
      }
    });
  }

  const newRef = likesRef.push();
  const id = newRef.key;

  if (!id) {
    throw new Error("Failed to generate like id");
  }

  const now = Date.now();
  const likeRecord = {
    id,
    postId: body.postId,
    userId,
    createdAt: now,
  };

  await newRef.set(likeRecord);

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes: likeRecord,
      links: {
        self: `${origin}/${entityType}/${id}`
      }
    }
  });
};
