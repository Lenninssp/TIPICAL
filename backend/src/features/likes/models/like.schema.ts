import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { LikeTable } from "./like.table";
import z from "zod";

export const SelectLikeSchema = createSelectSchema(LikeTable);

export const CreateLikeSchema = createInsertSchema(LikeTable, {
  postId: z.string().min(1).trim(),
}).omit({
  id: true,
  userId: true,
  createdAt: true,
});

export const LikeSchema = z
  .object(SelectLikeSchema.shape)
  .openapi({
    example: {
      id: "like_123",
      postId: "post_456",
      userId: "user_789",
      createdAt: 1738944000000,
    },
  })
  .openapi("Like");
