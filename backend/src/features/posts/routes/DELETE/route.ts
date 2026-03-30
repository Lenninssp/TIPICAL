import z from "zod";
import { createDeletionSuccessResponseSchema } from "../../../shared/responses/successResponse";
import { createRoute } from "@hono/zod-openapi";
import { ErrorResponseSchema } from "../../../shared/models/errorResponseSchema";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../../shared/responses/unauthorizedResponse";
import { notFoundResponse, NotFoundResponseSchema } from "../../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getDatabase } from "firebase-admin/database";
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
      description: "The deleted post id",
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
  const db = getDatabase();
  const origin = new URL(c.req.url).origin;
  const { id } = c.req.valid("param");

  const userId = getCurrentUserId(c);
  if (!userId) return unauthorizedResponse(c, "No user found");

  const postRef = db.ref(`posts/${id}`);

  const snap = await postRef.get();
  if (!snap.exists()) {
    return notFoundResponse(c, "The post doesn't exist");
  }

  const existing = (snap.val() ?? {}) as Record<string, unknown>;
  if (existing.userId && existing.userId !== userId) {
    return unauthorizedResponse(c, "You are not the owner of this post");
  }

  // Delete image from storage if it exists (Ticket 8)
  if (typeof existing.imagePath === "string" && existing.imagePath.trim() !== "") {
    try {
      await deletePostImage(existing.imagePath);
    } catch (err: unknown) {
      console.error("Failed to delete image during post deletion:", err);
      // We continue with post deletion even if image deletion fails.
    }
  }

  await postRef.remove();
  
  return c.json<z.infer<typeof ResponseSchema>, 200>({
    data: {
      id,
      type: entityType,
      attributes: { id },
      links: {
        self: `${origin}/${entityType}/${id}`,
      }
    }
  })

};
