import { z, type ZodRawShape } from "zod";

type EmptyZodShape = { [key: string]: never };

export const createSuccessResponseSchema = <
  T extends ZodRawShape,
  R extends ZodRawShape = EmptyZodShape,
  M extends ZodRawShape = EmptyZodShape,
  I extends ZodRawShape = EmptyZodShape
> (
  entityType: string,
  entitySchema: z.ZodObject<T>,
  relationshipSchema?: z.ZodObject<R>,
  metaSchema?: z.ZodObject<M>,
  includeSchema?: z.ZodObject<I>
) => 
  z.object({
    data: z.object({
      id: z.string().openapi({
        example: '1234567889',
      }),
      type: z.string().openapi({
        example: entityType,
      }),
      attributes: entitySchema.partial(),
      relationships: relationshipSchema ? relationshipSchema.optional() : z.object({}).optional(),
      links: z
        .object({
          self: z
            .string()
            .url()
            .optional()
            .openapi({
              example: `https://api.website.com/${entityType}/123456789`,
            }),
        })
        .optional(),
    }),
    meta: metaSchema ? metaSchema.optional() : z.object({}).optional(),
    included: includeSchema ? includeSchema.optional() : z.object({}).optional(),
  });

  
export const createDeletionSuccessResponseSchema = <M extends ZodRawShape = EmptyZodShape>(
  entityType: string,
  metaSchema?: z.ZodObject<M>,
) =>
  z.object({
    data: z.object({
      id: z.string().openapi({
        example: '123456789',
      }),
      type: z.string().openapi({
        example: entityType,
      }),
      attributes: z.object({
        id: z.string().openapi({ example: '123456789' }),
      }),
      links: z
        .object({
          self: z
            .url()
            .optional()
            .openapi({
              example: `https://api.website.com/${entityType}/123456789`,
            }),
        })
        .optional(),
    }),
    meta: metaSchema ? metaSchema.optional() : z.object({}).optional(), // https://jsonapi.org/format/#document-meta
  });