import z from "zod";
import { CollectionSuccessResponseSchema } from "../../shared/models/successResponseSchema";
import { CommentSchema } from "../models/comment.schema";
import { ErrorResponseSchema } from "../../shared/models/errorResponseSchema";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../shared/responses/unauthorizedResponse";
import { NotFoundResponseSchema } from "../../shared/responses/notFoundResponse";
import { createRoute } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { getCurrentUserId } from "../../auth/current-user";
import { getDatabase } from "firebase-admin/database";
import { pickObjectProperties } from "../../../utils/object";

const entityType = "comments";

const QuerySchema = z.object({
  fields: z.string().optional().openapi({ example: "comment,creationDate:"}),
  postId: z.string().optional().openapi({ example: "post_123 "}),
  userId: z.string().optional().openapi({ example: "user_123" }),
  hidden: z
    .union([z.literal("true"), z.literal("false")])
    .optional()
    .openapi({ example: "false" }),
  limit: z.coerce.number().min(1).max(100).optional().openapi({ example: 20 }),
});

interface RequestValidationTargets {
  out: {
    query: z.infer<typeof QuerySchema>
  };
}

const ResponseSchema = CollectionSuccessResponseSchema.merge(
  z.object({
    data: z.array(
      z.object({
        id: z.string().openapi({
          example: "comment_123",
        }),
        type: z.string().default(entityType).openapi({
          example: entityType,
        }),
        attributes: CommentSchema,
        links: z.object({
          self: z.string().url().openapi({
            example: "https://api.website.com/comments/comments_123"
          })
        })
      })
    )
  })
);

export const route = createRoute({
  method: "get",
  path: `/${entityType}`,
  request: {
    query: QuerySchema,
  },
  description: "Retrieve comments",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Retrieve comments",
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
  const userId = getCurrentUserId(c);

  if (!userId) {
    return unauthorizedResponse(c, "No user found")
  }

  const db = getDatabase();
  const commentsRef = db.ref(entityType);
  const snap = await commentsRef.get();

  const raw = (snap.val() ?? {}) as Record<string, any>;

  let comments = Object.entries(raw).map(([id, record]) => ({
    id, 
    record: {
      ...record,
      hidden: record?.hidden ?? false,
    }, 
  }));

  if (query.postId) {
    comments = comments.filter((c) => c.record.postId === query.postId);
  }

  if (query.userId) {
    comments = comments.filter((c) => c.record.userId === query.userId);
  }

  if (query.hidden) {
    const hiddenBool = query.hidden === "true";
    comments = comments.filter((c) => Boolean(c.record.hidden) === hiddenBool);
  }

  comments.sort(
    (a, b) => (a.record.creationDate ?? 0) - (b.record.creationDate ?? 0),
  );

  if (query.limit !== undefined) {
    comments = comments.slice(-query.limit);
  }

  const origin = new URL(c.req.url).origin;

return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: comments.map((comment) => ({
      id: comment.id,
      type: entityType,
      attributes: query.fields
        ? pickObjectProperties(
            comment.record,
            query.fields.split(",").map((field) => field.trim()),
          )
        : comment.record,
      links: {
        self: `${origin}/${entityType}/${comment.id}`,
      },
    })),
  });
}