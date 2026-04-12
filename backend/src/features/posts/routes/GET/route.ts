import z from "zod";
import { createRoute } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";

import { PostSchema } from "../../models/post.schema";
import { createSuccessResponseSchema } from "../../../shared/responses/successResponse";
import { ErrorResponseSchema } from "../../../shared/models/errorResponseSchema";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../../shared/responses/unauthorizedResponse";
import {
  notFoundResponse,
  NotFoundResponseSchema,
} from "../../../shared/responses/notFoundResponse";
import { getCurrentUserId } from "../../../auth/current-user";
import { pickObjectProperties } from "../../../../utils/object";

const entityType = "posts";

const ParamsSchema = z.object({
  id: z.string().min(1).openapi({
    param: {
      name: "id",
      in: "path",
    },
    example: "post_123",
  }),
});

const QuerySchema = z.object({
  fields: z.string().optional().openapi({
    example: "title,description,createdAt",
  }),
});

interface RequestValidationTargets {
  out: {
    param: z.infer<typeof ParamsSchema>;
    query: z.infer<typeof QuerySchema>;
  };
}

const ResponseSchema = createSuccessResponseSchema(entityType, PostSchema);

export const route = createRoute({
  method: "get",
  path: `/${entityType}/{id}`,
  request: {
    params: ParamsSchema,
    query: QuerySchema,
  },
  description: "Retrieve a single post by id",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Retrieve single post",
    },
    400: {
      content: {
        "application/json": {
          schema: ErrorResponseSchema,
        },
      },
      description: "Bad Request",
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
      description: "Not Found",
    },
  },
});

export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const { id } = c.req.valid("param");
  const query = c.req.valid("query");
  const userId = getCurrentUserId(c);

  if (!userId) {
    return unauthorizedResponse(c, "No user found");
  }

  const db = getDatabase();
  const snap = await db.ref(entityType).child(id).get();

  if (!snap.exists()) {
    return notFoundResponse(c, "Post not found");
  }

  const record = snap.val();
  const origin = new URL(c.req.url).origin;

  const allLikesSnap = await db.ref("post_likes").get();
  const allLikes = (allLikesSnap.val() ?? {}) as Record<string, any>;
  const likesArray = Object.values(allLikes).filter((l) => l.postId === id);

  const allCommentsSnap = await db.ref("comments").get();
  const allComments = (allCommentsSnap.val() ?? {}) as Record<string, any>;
  const commentsArray = Object.values(allComments).filter((c) => c.postId === id);

  const likeCount = likesArray.length;
  const likedByCurrentUser = likesArray.some((l) => l.userId === userId);
  const commentCount = commentsArray.length;

  const enrichedAttributes = {
    ...record,
    likeCount,
    commentCount,
    likedByCurrentUser,
  };

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes: query.fields
        ? pickObjectProperties(
            enrichedAttributes,
            query.fields.split(",").map((field) => field.trim()),
          )
        : enrichedAttributes,
      links: {
        self: `${origin}/${entityType}/${id}`,
      },
    },
  });
};
