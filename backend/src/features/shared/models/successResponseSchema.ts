import z from "zod";

// export const SuccessResponseSchema = z.object({
//   data: z
//     .object({
//       id: z.string().openapi({
//         example: '123456789'
//       }),
//       type: z.string().openapi({
//         example: 'posts'
//       }),
//       attributes: z.object({}).openapi({
//         example: {
//           id
//         }
//       })
//     })
// })

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
