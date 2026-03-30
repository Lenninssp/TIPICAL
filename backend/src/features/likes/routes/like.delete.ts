import z from "zod";
import { createRoute } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";

import { createDeletionSuccessResponseSchema } from "../../shared/responses/successResponse";
import { ErrorResponseSchema } from "../../shared/models/errorResponseSchema";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../shared/responses/unauthorizedResponse";
import {
  notFoundResponse,
  NotFoundResponseSchema,
} from "../../shared/responses/notFoundResponse";
import { getCurrentUserId } from "../../auth/current-user";

const entityType = "post_likes";

const ParamsSchema = z.object({
  postId: z.string().min(1).openapi({
    param: {
      name: "postId",
      in: "path",
    },
    example: "post_123",
  }),
});

interface RequestValidationTargets {
  out: {
    param: z.infer<typeof ParamsSchema>;
  };
}

const ResponseSchema = createDeletionSuccessResponseSchema(entityType);

export const route = createRoute({
  method: "delete",
  path: `/${entityType}/{postId}`,
  request: {
    params: ParamsSchema,
  },
  description: "Unlike a post",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The deleted like id",
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
      description: "Post not found",
    },
  },
});

export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const { postId } = c.req.valid("param");
  const currentUserId = getCurrentUserId(c);

  if (!currentUserId) {
    return unauthorizedResponse(c, "No user found");
  }

  const db = getDatabase();

  const postSnap = await db.ref("posts").child(postId).get();
  if (!postSnap.exists()) {
    return notFoundResponse(c, "Post not found");
  }

  const likesRef = db.ref(entityType);

  const allLikesSnap = await likesRef.get();
  const allLikes = (allLikesSnap.val() ?? {}) as Record<string, any>;

  let likeIdToDelete: string | null = null;
  for (const id in allLikes) {
    const val = allLikes[id];
    if (val.postId === postId && val.userId === currentUserId) {
      likeIdToDelete = id;
      break;
    }
  }

  const origin = new URL(c.req.url).origin;

  if (!likeIdToDelete) {
    return c.json<z.infer<typeof ResponseSchema>, 200>({
      data: {
        id: "none",
        type: entityType,
        attributes: { id: "none" },
        links: {
          self: `${origin}/${entityType}/none`,
        },
      },
    });
  }

  await likesRef.child(likeIdToDelete).remove();

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id: likeIdToDelete,
      type: entityType,
      attributes: { id: likeIdToDelete },
      links: {
        self: `${origin}/${entityType}/${likeIdToDelete}`,
      },
    },
  });
};
