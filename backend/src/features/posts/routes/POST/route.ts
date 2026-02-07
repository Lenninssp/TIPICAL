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
  const { getDatabase } = require("firebase-admin/database");
  const db = getDatabase();
  const ref = db.ref("https://tipical-bd8e7-default-rtdb.firebaseio.com");
  const origin = new URL(c.req.url).origin;
  const query = c.req.valid('query');
  const user = true;
  // here I should do the user check
  if (!user) {
    return unauthorizedResponse(c, "No user found");
  }

  // Insert into db

  const postsRef = ref.child("posts");
  postsRef.set({
    post_test: {
      posts: {
        post_123: {
          archived: false,
          createdAt: 1738944000000,
          description: "Some text...",
          editedAt: 1738944000000,
          image: {
            contentType: "image/jpeg",
            path: "posts/post_123/cover.jpg",
            updatedAt: 1738945000000,
            url: "https://firebasestorage.googleapis.com/v0/b/...optional...",
          },
          location: {
            lat: 45.5019,
            lng: -73.5674,
          },
          title: "My post title",
          userId: "user_abc",
        },
      },
    },
  });

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id: postsRef[0].id,
      type: entityType,
      attributes: query?.fields ? pickObjectProperties(postsRef[0], query?.fields.split(',')) : postsRef[0],
      links: {
        self: `${origin}/${entityType}/${postsRef[0].id}${buildUrlQueryString(query)}`
      }

    }
  })
};
