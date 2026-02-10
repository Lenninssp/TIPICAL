import { z } from "@hono/zod-openapi";
import type { Context } from "hono";

export const NotFoundResponseSchema = z.object({
  errors: z.array(
    z.object({
      status: z.literal(404),
      code: z.literal("NOT_FOUND"),
      title: z.literal("404 Not Found"),
      details: z.string().openapi({ default: "The resource does not exist" }),
    }),
  ),
});

export const notFoundResponse = (c: Context, message?: string) => {
  const url = new URL(c.req.url);
  c.status(404);
  return c.json<z.infer<typeof NotFoundResponseSchema>, 404>({
    errors: [
      {
        status: 404,
        code: "NOT_FOUND",
        title: "404 Not Found",
        details: message ?? "The resource doesn't exist",
      },
    ],
  });
};
