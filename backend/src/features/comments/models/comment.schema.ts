import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { CommentTable } from "./comment.table";
import z from "zod";

export const SelectCommentSchema = createSelectSchema(CommentTable);

export const CreateCommentSchema = createInsertSchema(CommentTable, {
  postId: z.string().min(1).trim(),
  comment: z.string().min(1).trim(),
}).omit({
  id: true,
  userId: true,
  hidden: true,
  creationDate: true,
  editionDate: true,
});

export const UpdateCommentSchema = z.object({
  comment: z.string().min(1).trim().optional(),
  hidden: z.boolean().optional(),
});

export const CommentSchema = z
  .object(SelectCommentSchema.shape)
  .openapi({
    example: {
      id: "comment_123",
      postId: "post_456",
      userId: "user_789",
      comment: "This is a sample comment.",
      hidden: false,
      creationDate: 1738944000000,
      editionDate: 1738944000000,
    },
  })
  .openapi("Comment");