import z, { record } from "zod";
import { PostSchema } from "../../../models/postSchema";
import { CollectionSuccessResponseSchema } from "../../../../shared/models/successResponseSchema";
import { createRoute } from "@hono/zod-openapi";
import { ErrorResponseSchema } from "../../../../shared/models/errorResponseSchema";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../../../shared/responses/unauthorizedResponse";
import { NotFoundResponseSchema } from "../../../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";
import { pickObjectProperties } from "../../../../../utils/object";
import { buildUrlQueryString } from "../../../../../utils/url";
import { createSuccessResponseSchema } from "../../../../shared/responses/successResponse";

const entityType = "posts-lists";

const QuerySchema = z.object({
  fields: z
    .string()
    .optional()
    .openapi({ example: "title,description,createdAt" }),

  userId: z.string().optional().openapi({ example: "user_abc" }),
  archived: z
    .union([z.literal("true"), z.literal("false")])
    .optional()
    .openapi({ example: "false" }),

  createdAfter: z.coerce
    .number()
    .optional()
    .openapi({ example: 1738944000000 }),
  createdBefore: z.coerce
    .number()
    .optional()
    .openapi({ example: 1739044000000 }),

  hasImage: z
    .union([z.literal("true"), z.literal("false")])
    .optional()
    .openapi({ example: "true" }),

  limit: z.coerce.number().min(1).max(100).optional().openapi({ example: 20 }),
});

interface RequestValidationTargets {
  out: {
    query: z.infer<typeof QuerySchema>;
  };
}

const PostAttributesSchema = PostSchema.partial();

const PostResourceSchema = z.object({
  id: z.string().openapi({ example: "post_123" }),
  type: z.literal(entityType).openapi({ example: entityType }),
  attributes: PostAttributesSchema,
  links: z.object({
    self: z.string().url().openapi({
      example: `https://api.website.com/${entityType}/post_123`,
    }),
  }),
});

const ResponseSchema = CollectionSuccessResponseSchema.extend(
  z.object({
    data: z.array(PostResourceSchema),
    links: z.object({
      self: z.string().url().openapi({
        example: `https://api.website.com/${entityType}?limit=20`,
      }),
      first: z.string().url().openapi({
        example: `https://api.website.com/${entityType}?limit=20`,
      }),
      last: z.string().url().openapi({
        example: `https://api.website.com/${entityType}?limit=20`,
      }),
      prev: z.string().url().openapi({
        example: `https://api.website.com/${entityType}?limit=20`,
      }),
      next: z.string().url().openapi({
        example: `https://api.website.com/${entityType}?limit=20`,
      }),
    }),
  }),
);

export const route = createRoute({
  method: "get",
  path: `/${entityType}`,
  request: {
    query: QuerySchema,
  },
  description: "Retrieve globally pusblished posts",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Retrieve posts",
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
      description: "not found",
    },
  },
});

export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const query = c.req.valid("query");

  // todo: replace for the real check
  const user = true;
  if (!user) return unauthorizedResponse(c, "No user found");

  const origin = new URL(c.req.url).origin;

  const db = getDatabase();
  const postsRef = db.ref("posts");

  let q = postsRef.orderByChild("createdAt");

  if (query.createdAfter !== undefined) q = q.startAt(query.createdAfter);
  if (query.createdBefore !== undefined) q = q.endAt(query.createdBefore);

  if (query.limit !== undefined) q = q.limitToLast(query.limit);
  const snap = await q.get();

  const raw = (snap.val() ?? {}) as Record<string, any>;

  let posts = Object.entries(raw).map(([id, record]) => ({
    id,
    record: {
      ...record,
      archived: record?.archived ?? false,
      userId: record?.userId ?? null,
    },
  }));

  if (query.userId) {
    posts = posts.filter((p) => p.record.userId === query.userId);
  }

  if (query.archived) {
    const archivedBool = query.archived === "true";
    posts = posts.filter((p) => Boolean(p.record.archived) === archivedBool);
  }

  if (query.hasImage) {
    const hasImageBool = query.hasImage === "true";
    posts = posts.filter((p) => Boolean(p.record?.image?.url) === hasImageBool);
  }

  posts.sort((a, b) => (a.record.createdAt ?? 0) - (b.record.createdAt ?? 0));
  if (query.limit !== undefined) {
    posts = posts.slice(-query.limit);
  }

  const fieldsRaw =
    typeof query?.fields === "string" ? String(query.fields) : undefined;

  const fields = fieldsRaw?.includes(",")
    ? fieldsRaw
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean)
    : fieldsRaw
      ? [fieldsRaw.trim()]
      : undefined;


   const self = `${origin}/${entityType}${buildUrlQueryString(query as any)}`;

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: posts.map(({ id, record }) => {
      const base = { id, ...record };
      const attributes = fields ? pickObjectProperties(base, fields) : base;

      return {
        id,
        type: entityType,
        attributes,
        links: {
          self: `${origin}/${entityType}/${id}`,
        },
      };
    }),
    links: {
      self,
      first: self,
      last: self,
      prev: self,
      next: self,
    },
  });
};
