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

const entityType = "comments";

const ParamsSchema = z.object({
  id: z.string().min(1).openapi({
    param: {
      name: "id",
      in: "path",
    },
    example: "comment_123",
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
  path: `/${entityType}/{id}`,
  request: {
    params: ParamsSchema,
  },
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The deleted comment id",
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
  const { id } = c.req.valid("param");
  const currentUserId = getCurrentUserId(c);

  if (!currentUserId) {
    return unauthorizedResponse(c, "No user found");
  }

  const db = getDatabase();
  const commentRef = db.ref(`${entityType}/${id}`);
  const snap = await commentRef.get();

  if (!snap.exists()) {
    return notFoundResponse(c, "The comment doesn't exist");
  }

  const existing = (snap.val() ?? {}) as Record<string, any>;

  if (existing.userId !== currentUserId) {
    return unauthorizedResponse(c, "You are not the owner of this comment");
  }

  await commentRef.remove();

  const origin = new URL(c.req.url).origin;

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes: { id },
      links: {
        self: `${origin}/${entityType}/${id}`,
      },
    },
  });
};