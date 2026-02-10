import z from "zod";
import { PostSchema } from "../../models/postSchema";
import { CollectionSuccessResponseSchema } from "../../../shared/models/successResponseSchema";
import { createRoute } from "@hono/zod-openapi";

const entityType = "posts";

const fieldKeys = Object.keys(PostSchema.shape) as [string];

const QuerySchema = z.object({
  fields: z.enum<typeof fieldKeys>(fieldKeys).optional(),
  include: z.enum(["assignee"]).optional(),
  listId: z.string().optional().openapi({ example: "123456789" }),
  teamId: z.string().optional().openapi({ example: "123456789" }),
});

interface RequestValidationTargets {
  out: {
    query: z.infer<typeof QuerySchema>;
  };
}

const ResponseSchema = CollectionSuccessResponseSchema.extend(
  z.object({
    data: z.array(
      z.object({
        id: z.string().openapi({
          example: entityType,
        }),
        type: z.string().default(entityType).openapi({
          example: entityType,
        }),
        attributes: PostSchema,
        relationships: z
          .object({
            assignee: z.object({
              data: z.object({
                id: z.string().openapi({}),
                example: "thgbw45brtb4rt5676uh",
              }),
              type: z.string().openapi({
                example: "users",
              }),
            }),
          })
          .optional(),
        links: z.object({
          self: z
            .string()
            .url()
            .openapi({
              example: `https://api.website.com/${entityType}/thgbw45brtb4rt5676uh`,
            }),
        }),
      }),
    ),
    included: z.array(
      z.object({
        id: z.string().openapi({
          example: "thgbw45brtb4rt5676uh",
        }),
        type: z.string().openapi({
          example: "users",
        }),
        attributes: z.object({
          id: z.string().openapi({
            example: "thgbw45brtb4rt5676uh",
          }),
          fullName: z.string().openapi({
            example: "John Doe",
          }),
        }),
        links: z.object({
          self: z.url().openapi({
            example: "https://api.website.com/users/thgbw45brtb4rt5676uh",
          }),
        }),
      }),
    ),
  }),
);

export const route = createRoute({
  method: 'get',
  path: `/${entityType}`,
  request: {
    query: QuerySchema,
  },
  description: 'Retrieve globally pusblished posts',
  responses: {
    200: {
      content: {
        'application/json': {
          schema: ResponseSchema,
        },
      },
      description: 'Retrieve posts',
    },
    400: {
      content: {
        'application/json': {
          schema: ,
        }
      }
    }
  }
})