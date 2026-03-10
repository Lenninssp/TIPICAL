import z from "zod";

export const SuccessResponseSchema = z.object({
  data: z
    .object({
      id: z.string().openapi({
        example: "123456789",
      }),
      type: z.string().openapi({
        example: "posts",
      }),
      attributes: z.object({}).openapi({
        // https://jsonapi.org/format/#document-resource-object-attributes
        example: {
          id: "123e4567-e89b-12d3-a456-426614174000",
          title: "Sample Post",
          description: "This is a sample description for the post.",
          createdAt: 1738944000000,
          editedAt: 1738944000000,
          ownerId: "456e7890-e12b-34d5-a678-526614174001",
          archived: false,
          latitude: 40.7128,
          longitude: -74.006,
        },
      }),
      relationships: z
        .object({})
        .optional()
        .openapi({
          // https://jsonapi.org/format/#document-resource-object-relationships
          example: {
            user: {
              data: {
                id: "123456789",
                type: "user",
                attributes: { title: "John Smith" },
              },
            },
            comments: [
              {
                data: {
                  id: "123456789",
                  type: "comment",
                  attributes: { title: "Great job!" },
                },
              },
            ],
          },
        }),
      links: z
        .object({
          self: z.string().url().optional().openapi({
            example: "https://api.website.com/tasks/123456789",
          }),
        })
        .optional(),
    })
    .openapi({}),
  meta: z.object({}).optional().openapi({}), // https://jsonapi.org/format/#document-meta
  included: z.object({}).optional().openapi({}),
});

export const CollectionSuccessResponseSchema = z.object({
  data: z.array(
    z
      .object({
        id: z.string().openapi({
          example: "123456789",
        }),
        type: z.string().openapi({
          example: "posts",
        }),
        attributes: z.object({}).openapi({}),
        relationsips: z
          .object({})
          .optional()
          .openapi({
            example: {
              user: {
                data: {
                  id: "123456789",
                  type: "user",
                  attributes: {
                    title: "John Doe",
                  },
                },
              },
              comments: [
                {
                  data: {
                    id: "123456788",
                    type: "comment",
                    attributes: { title: "Great Job! " },
                  },
                },
              ],
            },
          }),
        links: z
          .object({
            self: z.url().optional().openapi({
              example: "https://api.website.com/tasks/123456789",
            }),
          })
          .optional(),
      })
      .openapi({}),
  ),
  links: z
    .object({
      self: z.url().openapi({
        example:
          "https://api.website.com/tasks?fields=id,title&sort=-createdAt&filter[isCompleted]=true&page[limit]=10&page[number]=2",
      }),
      first: z.url().openapi({
        example:
          "https://api.website.com/tasks?fields=id,title&sort=-createdAt&filter[isCompleted]=true&page[limit]=10&page[number]=1",
      }),
      last: z.url().openapi({
        example:
          "https://api.website.com/tasks?fields=id,title&sort=-createdAt&filter[isCompleted]=true&page[limit]=10&page[number]=12",
      }),
      prev: z.url().openapi({
        example:
          "https://api.website.com/tasks?fields=id,title&sort=-createdAt&filter[isCompleted]=true&page[limit]=10&page[number]=1",
      }),
      next: z.url().openapi({
        example:
          "https://api.website.com/tasks?fields=id,title&sort=-createdAt&filter[isCompleted]=true&page[limit]=10&page[number]=3", // page[cursor]=sdfa
      }),
    })
    .optional()
    .openapi({}),
  meta: z.object({}).optional().openapi({}),
  included: z.object({}).optional().openapi({}),
});
