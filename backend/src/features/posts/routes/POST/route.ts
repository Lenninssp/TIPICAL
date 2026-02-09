import type { Context, Env } from "hono";
import { CreatePostSchema, PostSchema } from "../../models/postSchema";
import { createRoute, z } from "@hono/zod-openapi";
import { createSuccessResponseSchema } from "../../../shared/responses/successResponse";
import { InvalidInputResponseSchema } from "../../../shared/responses/invalidInputResponse";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../../shared/responses/unauthorizedResponse";
import { NotFoundResponseSchema } from "../../../shared/responses/notFoundResponse";
import { pickObjectProperties } from "../../../../utils/object";
import { buildUrlQueryString } from "../../../../utils/url";
import { getDatabase } from "firebase-admin/database";

const entityType = "posts";

const fieldKeys = Object.keys(PostSchema.shape) as [string];

const QuerySchema = z.object({
  fields: z.enum<typeof fieldKeys>(fieldKeys).optional(),
});

interface RequestValidationTargets {
  out: {
    query: z.infer<typeof QuerySchema>;
    json: z.infer<typeof CreatePostSchema>;
  };
}

const ResponseSchema = createSuccessResponseSchema(entityType, PostSchema);

export const route = createRoute({
  method: "post",
  path: `/${entityType}`,
  request: {
    query: QuerySchema,
    body: {
      content: {
        "application/json": {
          schema: CreatePostSchema,
        },
      },
      required: true,
    },
    description: "Data to create a new post from",
  },
  description: "Create a new Post for a given user",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The new Post",
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
  const query = c.req.valid("query");
  const body = c.req.valid("json");
  
  const user = true;
  if (!user) return unauthorizedResponse(c, "No user found");

  const origin = new URL(c.req.url).origin;

  const db = getDatabase();
  const postsRef = db.ref("posts");

  const newRef = postsRef.push();
  const id = newRef.key!;
  const now = Date.now();

  const record = {
    ...body,
    userId: (body as any).userId ?? "user_abc", 
    archived: (body as any).archived ?? false,
    createdAt: now,
    updatedAt: now,
    editedAt: now,
  };

  await newRef.set(record);
  
  const fieldsRaw =
    typeof (query as any)?.fields === "string" ? String((query).fields) : undefined;
  const fields = fieldsRaw?.includes(",") ? fieldsRaw.split(",") : fieldsRaw ? [fieldsRaw] : undefined;

  const attributes = fields
    ? pickObjectProperties({ id, ...record }, fields)
    : { id, ...record };

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

/**
curl -d '{"title": "Lennin test", "description": "This is a description" }' -H "Content-Type: application/json" -X POST http://localhost:3000/posts
 */
