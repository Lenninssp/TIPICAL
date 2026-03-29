import { createRoute, z } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { deletePostImage } from "../../../../shared/lib/firebase-storage";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../../../shared/responses/unauthorizedResponse";
import { getCurrentUserId } from "../../../../auth/current-user";
import { createDeletionSuccessResponseSchema } from "../../../../shared/responses/successResponse";
import { ErrorResponseSchema } from "../../../../shared/models/errorResponseSchema";
import { randomUUID } from "crypto";

const entityType = "posts/upload";

const ImageDeleteSchema = z.object({
  imagePath: z.string().openapi({
    description: "The Firebase Storage path of the image to delete",
    example: "posts/abc-123.jpg",
  }),
});

const ResponseSchema = createDeletionSuccessResponseSchema("upload");

export const route = createRoute({
  method: "delete",
  path: `/posts/upload`,
  request: {
    body: {
      content: {
        "application/json": {
          schema: ImageDeleteSchema,
        },
      },
      required: true,
    },
  },
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Delete successful",
    },
    400: {
      content: {
        "application/json": {
          schema: ErrorResponseSchema,
        },
      },
      description: "Invalid input",
    },
    401: {
      content: {
        "application/json": {
          schema: UnauthorizedResponseSchema,
        },
      },
      description: "Unauthorized",
    },
    500: {
      content: {
        "application/json": {
          schema: ErrorResponseSchema,
        },
      },
      description: "Server error",
    },
  },
});

export const handler = async (c: Context<Env>) => {
  const userId = getCurrentUserId(c);
  if (!userId) return unauthorizedResponse(c, "No user found");

  const { imagePath } = await c.req.json() as { imagePath: string };

  if (!imagePath || typeof imagePath !== "string") {
    return c.json(
      {
        errors: [
          {
            id: randomUUID(),
            status: 400,
            code: "INVALID_INPUT",
            title: "Invalid input",
            details: "imagePath is required and must be a string",
            source: { pointer: "/imagePath" },
            links: { about: "", type: "" }
          },
        ],
      },
      400,
    );
  }

  try {
    await deletePostImage(imagePath);

    return c.json({
      data: {
        id: "upload",
        type: "upload",
        attributes: { id: imagePath },
        links: {
          self: c.req.url,
        },
      },
    }, 200);
  } catch (err: unknown) {
    console.error("Manual image delete error:", err);
    const url = new URL(c.req.url);
    const errorMessage = err instanceof Error ? err.message : "Unknown error";
    
    return c.json(
      {
        errors: [
          {
            id: randomUUID(),
            status: 500,
            code: "SERVER_ERROR",
            title: "Failed to delete image",
            details: errorMessage,
            source: {
                pointer: "/imagePath"
            },
            links: {
                about: `https://${url.origin}/docs/errors/SERVER_ERROR`,
                type: `https://${url.origin}/docs/errors`
            }
          },
        ],
      },
      500,
    );
  }
};
