import z from "zod";
import { createRoute } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";

import { CollectionSuccessResponseSchema } from "../../shared/models/successResponseSchema";
import { ErrorResponseSchema } from "../../shared/models/errorResponseSchema";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../shared/responses/unauthorizedResponse";
import { NotFoundResponseSchema } from "../../shared/responses/notFoundResponse";
import { getCurrentUserId } from "../../auth/current-user";
import { LikeSchema } from "../models/like.schema";

const entityType = "post_likes";

const QuerySchema = z.object({
  postId: z.string().optional().openapi({ example: "post_123" }),
  userId: z.string().optional().openapi({ example: "user_123" }),
  targetUserId: z.string().optional().openapi({ example: "user_owner_123" }),
  limit: z.coerce.number().min(1).max(100).optional().openapi({ example: 20 }),
});

const LikeListSchema = LikeSchema.extend({
  postTitle: z.string().optional(),
  postOwnerUserId: z.string().optional(),
});

interface RequestValidationTargets {
  out: {
    query: z.infer<typeof QuerySchema>;
  };
}

const ResponseSchema = CollectionSuccessResponseSchema.merge(
  z.object({
    data: z.array(
      z.object({
        id: z.string(),
        type: z.string().default(entityType),
        attributes: LikeListSchema,
        links: z.object({
          self: z.string().url(),
        }),
      }),
    ),
  }),
);

export const route = createRoute({
  method: "get",
  path: `/${entityType}`,
  request: {
    query: QuerySchema,
  },
  description: "Retrieve likes, optionally filtered by liked post, liking user, or post owner",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Retrieve likes",
    },
    400: {
      content: {
        "application/json": {
          schema: ErrorResponseSchema,
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
      description: "Not found",
    },
  },
});

export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const query = c.req.valid("query");
  const currentUserId = getCurrentUserId(c);

  if (!currentUserId) {
    return unauthorizedResponse(c, "No user found");
  }

  const db = getDatabase();
  const likesSnap = await db.ref(entityType).get();
  const postsSnap = await db.ref("posts").get();

  const likesRaw = (likesSnap.val() ?? {}) as Record<string, any>;
  const postsRaw = (postsSnap.val() ?? {}) as Record<string, any>;

  let likes = Object.entries(likesRaw).map(([id, record]) => {
    const post = postsRaw[record?.postId ?? ""] ?? null;

    return {
      id,
      record: {
        ...record,
        postTitle: post?.title,
        postOwnerUserId: post?.userId,
      },
    };
  });

  if (query.postId) {
    likes = likes.filter((like) => like.record.postId === query.postId);
  }

  if (query.userId) {
    likes = likes.filter((like) => like.record.userId === query.userId);
  }

  if (query.targetUserId) {
    likes = likes.filter((like) => like.record.postOwnerUserId === query.targetUserId);
  }

  likes.sort((a, b) => (b.record.createdAt ?? 0) - (a.record.createdAt ?? 0));

  if (query.limit !== undefined) {
    likes = likes.slice(0, query.limit);
  }

  const origin = new URL(c.req.url).origin;

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: likes.map((like) => ({
      id: like.id,
      type: entityType,
      attributes: like.record,
      links: {
        self: `${origin}/${entityType}/${like.id}`,
      },
    })),
  });
};
