import z from "zod";
import { createRoute } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";

import { CommentSchema } from "../models/comment.schema";
import { SuccessResponseSchema } from "../../shared/models/successResponseSchema";
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
import { pickObjectProperties } from "../../../utils/object";

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
    example: "comment,creationDate",
  }),
});

interface RequestValidationTargets {
  out: {
    param: z.infer<typeof ParamsSchema>;
    query: z.infer<typeof QuerySchema>;
  };
}

const ResponseSchema = SuccessResponseSchema.merge(
  z.object({
    data: z.object({
      id: z.string().openapi({
        example: "comment_123",
      }),
      type: z.string().default(entityType).openapi({
        example: entityType,
      }),
      attributes: CommentSchema,
      links: z.object({
        self: z.string().url().openapi({
          example: "https://api.website.com/comments/comment_123",
        }),
      }),
    }),
  }),
);

export const route = createRoute({
  method: "get",
  path: `/${entityType}/{id}`,
  request: {
    params: ParamsSchema,
    query: QuerySchema,
  },
  description: "Retrieve a single comment by id",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Retrieve single comment",
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
    return notFoundResponse(c, "Comment not found");
  }

  const record = snap.val();
  const origin = new URL(c.req.url).origin;

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes: query.fields
        ? pickObjectProperties(
            record,
            query.fields.split(",").map((field) => field.trim()),
          )
        : record,
      links: {
        self: `${origin}/${entityType}/${id}`,
      },
    },
  });
};