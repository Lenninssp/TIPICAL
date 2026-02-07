import type { Context, Env } from "hono";
import { CreatePostSchema, PostSchema } from "../../models/postSchema";
import {createRoute, z} from '@hono/zod-openapi'
import { createSuccessResponseSchema } from "../../../shared/responses/successResponse";


const entityType = 'posts';

const fieldKeys = Object.keys(PostSchema.shape) as [string];

const QuerySchema = z.object({
  fields: z.enum<typeof fieldKeys>(fieldKeys).optional(),
});

interface RequestValidationTargets {
  out: {
    query: z.infer<typeof QuerySchema>;
    json: z.infer<typeof CreatePostSchema>
  }
}

const ResponseSchema = createSuccessResponseSchema(entityType, PostSchema);

export const route = createRoute({
  method: 'post',
  path: `/${entityType}`,
  request: {
    query: QuerySchema,
    body: {
      content: {
        'application/json': {
          schema: CreatePostSchema,
        },
      },
      required: true,
    },
    description: 'Data to create a new post from',
  },
  description: 'Create a new Post for a given user',
  responses: {
    200: {
      content: {
        'application/json': {
          schema: ResponseSchema
        },
      },
      description: 'The new Post',
    },
    400: {
      content: {
        'application/json': {
          schema: 
        }
      }
    }
  }
  
})


export const handler = async (c: Context<Env, typeof ent)