import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { PostTable } from "./postTable";
import z from "zod";

export const SelectPostSchema = createSelectSchema(PostTable);

export const CreatePostSchema = createInsertSchema(PostTable, {
  title: z.string().min(1).trim(),
  description: z.string().min(1),
}).omit({
  id: true,
  ownerId: true,
  createdAt: true,
  editedAt: true,
  archived: true,
  latitude: true,
  longitude: true,
});

export const UpdateTaskSchema = CreatePostSchema.partial();

export const PostSchema = z
  .object(SelectPostSchema.shape)
  .openapi({
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
  })
  .openapi("Post");
