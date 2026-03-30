import z from "zod";
import {
  PostSchema,
  UpdatePostSchema,
} from "../../models/post.schema";
import { createSuccessResponseSchema } from "../../../shared/responses/successResponse";
import { createRoute } from "@hono/zod-openapi";
import { InvalidInputResponseSchema } from "../../../shared/responses/invalidInputResponse";
import {
  unauthorizedResponse,
  UnauthorizedResponseSchema,
} from "../../../shared/responses/unauthorizedResponse";
import {
  notFoundResponse,
  NotFoundResponseSchema,
} from "../../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";
import { pickObjectProperties } from "../../../../utils/object";
import { buildUrlQueryString } from "../../../../utils/url";
import { getCurrentUserId } from "../../../auth/current-user";
import { deletePostImage } from "../../../shared/lib/firebase-storage";

const entityType = "posts";

const ParamsSchema = z.object({
  id: z
    .string()
    .min(3)
    .openapi({
      param: {
        name: "id",
        in: "path",
      },
      example: "123456789",
    }),
});

const fieldKeys = Object.keys(PostSchema.shape) as [string];
const QuerySchema = z.object({
  fields: z.enum<typeof fieldKeys>(fieldKeys).optional(),
});

interface RequestValidationTargets {
  out: {
    param: z.infer<typeof ParamsSchema>;
    query: z.infer<typeof QuerySchema>;
    json: z.infer<typeof UpdatePostSchema>;
  };
}

const ResponseSchema = createSuccessResponseSchema(entityType, PostSchema);

export const route = createRoute({
  method: "patch",
  path: `/${entityType}/{id}`,
  request: {
    query: QuerySchema,
    params: ParamsSchema,
    body: {
      content: {
        "application/json": {
          schema: UpdatePostSchema,
        },
      },
      required: true,
    },
    description: "Data to update Post with",
  },
  description: "Update given Post",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "The updated post",
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
      description: "unauthorized",
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
  const userId = getCurrentUserId(c);
  if (!userId) return unauthorizedResponse(c, "No user found");
  
  const origin = new URL(c.req.url).origin;
  const db = getDatabase();

  const postRef = db.ref(`posts/${id}`);

  const snap = await postRef.get();
  if (!snap.exists()) {
    return notFoundResponse(c, "Post not found");
  }

  const existing = (snap.val() ?? {}) as Record<string, unknown>;
  if (existing.userId && existing.userId !== userId) {
    return unauthorizedResponse(c, "You are not the owner of this post");
  }

  const now = Date.now();

  const patch: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(body)) {
    if (v !== undefined) patch[k] = v;
  }

  // Handle image replacement (Ticket 9)
  if (patch.imagePath !== undefined && patch.imagePath !== existing.imagePath) {
    if (typeof existing.imagePath === "string" && existing.imagePath.trim() !== "") {
      try {
        await deletePostImage(existing.imagePath);
      } catch (err: unknown) {
        console.error("Failed to delete old image during update:", err);
      }
    }
  }

  // Define a typed version of the update object
  const updatePayload: Record<string, unknown> = {
    ...patch,
    updatedAt: now,
    editedAt: now,
  };

  // Ensure internal fields are not overwritten by the patch
  delete updatePayload.createdAt;
  delete updatePayload.userId;

  await postRef.update(updatePayload);

  const updated = { ...existing, ...updatePayload };

  const fieldsRaw =
    typeof query?.fields === "string" ? String(query.fields) : undefined;
  const fields = fieldsRaw?.includes(",")
    ? fieldsRaw.split(",")
    : fieldsRaw
      ? [fieldsRaw]
      : undefined;

  const attributes = fields
    ? pickObjectProperties({ id, ...updated }, fields)
    : { id, ...updated };

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
