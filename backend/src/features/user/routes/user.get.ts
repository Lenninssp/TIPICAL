import z from "zod";
import { UserSchema } from "../models/user.schema";
import { SuccessResponseSchema } from "../../shared/models/successResponseSchema";
import { createRoute } from "@hono/zod-openapi";
import { ErrorResponseSchema } from "../../shared/models/errorResponseSchema";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../shared/responses/unauthorizedResponse";
import {
  notFoundResponse,
  NotFoundResponseSchema,
} from "../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getCurrentUser } from "../../auth/current-user";
import { getDatabase } from "firebase-admin/database";
import { pickObjectProperties } from "../../../utils/object";

const entityType = "profiles";

const ParamsSchema = z.object({
  id: z
    .string()
    .min(1)
    .openapi({
      param: {
        name: "id",
        in: "path",
      },
      example: "me",
    }),
});

const QuerySchema = z.object({
  fields: z.string().optional().openapi({
    example: "email,displayName,createdAt",
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
        example: "user_abc",
      }),
      type: z.string().default(entityType).openapi({
        example: entityType,
      }),
      attributes: UserSchema,
      links: z.object({
        self: z.string().url().openapi({
          example: "https://api.website.com/users/user_abc",
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
  description: `Retrieve a single profile by ID. Use "me" to retrieve the current user's profile.`,
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Retrieve single user",
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
  const db = getDatabase();
  const origin = new URL(c.req.url).origin;
  const params = c.req.valid("param");
  const query = c.req.valid("query");

  const currentUser = await getCurrentUser(c);
  if (!currentUser) {
    return unauthorizedResponse(c);
  }

  const requestedId = params.id === "me" ? currentUser.id : params.id;

  if (requestedId !== currentUser.id) {
    return unauthorizedResponse(c);
  }

  const profileSnap = await db.ref(entityType).child(requestedId).get();

  if (!profileSnap.exists()) {
    return notFoundResponse(c);
  }

  const profileRecord = profileSnap.val();

  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id: requestedId,
      type: entityType,
      attributes: query.fields
        ? pickObjectProperties(
            profileRecord,
            query.fields.split(",").map((field) => field.trim()),
          )
        : profileRecord,
      links: {
        self: `${origin}/${entityType}/${requestedId}`,
      },
    },
  });
};
