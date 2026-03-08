import z from "zod";
import { SuccessResponseSchema } from "../../shared/models/successResponseSchema";
import { UserSchema } from "../models/user.schema";
import { createRoute } from "@hono/zod-openapi";
import { ErrorResponseSchema } from "../../shared/models/errorResponseSchema";
import { unauthorizedResponse, UnauthorizedResponseSchema } from "../../shared/responses/unauthorizedResponse";
import { notFoundResponse, NotFoundResponseSchema } from "../../shared/responses/notFoundResponse";
import type { Context, Env } from "hono";
import { getCurrentUser } from "../../auth/current-user";
import { getDatabase } from "firebase-admin/database";

const entityType = "profiles";

const BodySchema = z
  .object({
    firstName: z.string().min(1).optional(),
    lastName: z.string().min(1).optional(),
    description: z.string().optional(),
    birthDate: z.number().nullable().optional(),
    profilePicture: z.string().optional(),
    username: z.string().min(1).optional(),
  })
  .refine((value) => Object.keys(value).length > 0, {
    message: "At least one field must be provided",
  });

interface RequestValidationTargets {
  out: {
    json: z.infer<typeof BodySchema>;
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
          example: "https://api.website.com/profiles/user_abc",
        }),
      }),
    }),
  }),
);

export const route = createRoute({
  method: "patch",
  path: `/${entityType}/me`,
  request: {
    body: {
      content: {
        "application/json": {
          schema: BodySchema,
        },
      },
      description: "Editable profile fields",
    },
  },
  description: "Update the current user's profile",
  responses: {
    200: {
      content: {
        "application/json": {
          schema: ResponseSchema,
        },
      },
      description: "Profile updated successfully",
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
      description: "Profile not found",
    },
  },
});


export const handler = async (
  c: Context<Env, typeof entityType, RequestValidationTargets>,
) => {
  const currentUser = await getCurrentUser(c);
  if(!currentUser) {
    return unauthorizedResponse(c)
  }

  const profileId = currentUser.id;
  const db = getDatabase();
  const profileRef = db.ref(entityType).child(profileId);
  const profileSnap = await profileRef.get();

  if (!profileSnap.exists()) {
    return notFoundResponse(c, "profile not found");
  }

  const patch = c.req.valid("json");
  const existingProfile = profileSnap.val();
  const updatedProfile = {
    ...existingProfile,
    ...patch,
  }

  await profileRef.update(patch);

  const origin = new URL(c.req.url).origin;

  return c.json<z.infer<typeof ResponseSchema>, 200> ({
    data: {
      id: profileId,
      type: entityType,
      attributes: updatedProfile,
      links: {
        self: `${origin}/${entityType}/${profileId}`
      }
    }
  })

}