import { createRoute, z } from "@hono/zod-openapi";
import type { Context, Env } from "hono";
import { uploadPostImage } from "../../../../shared/lib/firebase-storage";
import { createSuccessResponseSchema } from "../../../../shared/responses/successResponse";
import { InvalidInputResponseSchema, invalidInputResponse } from "../../../../shared/responses/invalidInputResponse";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../../../shared/responses/unauthorizedResponse";
import { getCurrentUserId } from "../../../../auth/current-user";
import { ErrorResponseSchema } from "../../../../shared/models/errorResponseSchema";
import { randomUUID } from "crypto";

const entityType = "posts/upload";

const ImageUploadSchema = z.object({
  image: z.instanceof(File).openapi({
    type: "string",
    format: "binary",
    description: "The image to upload",
  }),
});

const ResponseSchema = createSuccessResponseSchema("upload", z.object({
  imageUrl: z.string().openapi({ example: "https://storage.googleapis.com/..." }),
  imagePath: z.string().openapi({ example: "posts/abc-123.jpg" }),
}));

export const route = createRoute({
  method: "post",
  path: `/posts/upload`,
  request: {
    body: {
      content: {
        "multipart/form-data": {
          schema: ImageUploadSchema,
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Upload successful",
    },
    400: {
      content: {
        "application/json": {
          schema: InvalidInputResponseSchema,
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

  const body = await c.req.parseBody();
  const file = body["image"] as File;

  if (!file || !(file instanceof File)) {
    return invalidInputResponse(c, [
      {
        code: "custom",
        path: ["image"],
        message: "No file uploaded or invalid file format",
      },
    ]);
  }

  try {
    const arrayBuffer = await file.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    const { imageUrl, imagePath } = await uploadPostImage(buffer, file.type);

    return c.json({
      data: {
        id: "upload",
        type: "upload",
        attributes: {
          imageUrl,
          imagePath,
        },
        links: {
          self: c.req.url,
        },
      },
    }, 200);
  } catch (err: any) {
    console.error("Upload error:", err);
    const url = new URL(c.req.url);
    return c.json(
      {
        errors: [
          {
            id: randomUUID(),
            status: 500,
            code: "SERVER_ERROR",
            title: "Failed to upload image",
            details: err.message,
            source: {
                pointer: "/image"
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
