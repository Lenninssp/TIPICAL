import z from "zod";
import { createRoute } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";

import { CommentSchema, UpdateCommentSchema } from "../models/comment.schema";
import { createSuccessResponseSchema } from "../../shared/responses/successResponse";
import { InvalidInputResponseSchema } from "../../shared/responses/invalidInputResponse";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../shared/responses/unauthorizedResponse";
import {
  notFoundResponse,
  NotFoundResponseSchema,
} from "../../shared/responses/notFoundResponse";
import { getCurrentUserId } from "../../auth/current-user";
import { pickObjectProperties } from "../../../utils/object";
import { buildUrlQueryString } from "../../../utils/url";

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

const QuerySchema = z.object({
  fields: z.string().optional().openapi({
    example: "comment,editionDate",
  }),
});

interface RequestValidationTargets {
  out: {
    param: z.infer<typeof ParamsSchema>;
    query: z.infer<typeof QuerySchema>;
    json: z.infer<typeof UpdateCommentSchema>;
  };
}

const ResponseSchema = createSuccessResponseSchema(entityType, CommentSchema);

export const route = createRoute({
  method: "patch",
  path: `/${entityType}/{id}`,
  request: {
    query: QuerySchema,
    params: ParamsSchema,
    body: {
      content: {
        "application/json": {
          schema: UpdateCommentSchema,
        },
      },
      required: true,
    },
  },
  description: "Update given comment",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The updated comment",
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
      description: "Not found",
    },
  },
});

export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const { id } = c.req.valid("param");
  const query = c.req.valid("query");
  const body = c.req.valid("json");
  const currentUserId = getCurrentUserId(c);

  if (!currentUserId) {
    return unauthorizedResponse(c, "No user found");
  }

  const origin = new URL(c.req.url).origin;
  const db = getDatabase();
  const commentRef = db.ref(`${entityType}/${id}`);

  const snap = await commentRef.get();
  if (!snap.exists()) {
    return notFoundResponse(c, "Comment not found");
  }

  const existing = (snap.val() ?? {}) as Record<string, any>;

  if (existing.userId !== currentUserId) {
    return unauthorizedResponse(c, "You are not the owner of this comment");
  }

  const patch: Record<string, any> = {};
  for (const [k, v] of Object.entries(body)) {
    if (v !== undefined) patch[k] = v;
  }

  delete patch.id;
  delete patch.postId;
  delete patch.userId;
  delete patch.creationDate;

  patch.editionDate = Date.now();

  await commentRef.update(patch);

  const updated = { ...existing, ...patch };

  const attributes = query.fields
    ? pickObjectProperties(
        updated,
        query.fields.split(",").map((field) => field.trim()),
      )
    : updated;

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes,
      links: {
        self: `${origin}/${entityType}/${id}${buildUrlQueryString(query)}`,
      },
    },
  });
};