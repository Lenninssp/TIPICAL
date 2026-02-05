import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { PostTable } from "./postTable";
import z from "zod";

export const SelectPostSchema = createSelectSchema(PostTable);

export const CreatePostSchema = createInsertSchema(PostTable, {
  title: z.string().min(1).trim(),
  description: z.string().min(1),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
}).omit({
  id: true,
  ownerId: true,
  createdAt: true,
  editedAt: true,
  archived: true,
});

export const UpdateTaskSchema = CreatePostSchema.partial();

export const PostSchema = z
  .object(SelectPostSchema.shape)
  .openapi({
    example: {
      id: "123e4567-e89b-12d3-a456-426614174000",
      title: "Sample Post",
      description: "This is a sample description for the post.",
      createdAt: "2023-01-01T00:00:00Z",
      editedAt: "2023-01-02T00:00:00Z",
      ownerId: "456e7890-e12b-34d5-a678-526614174001",
      archived: false,
      latitude: 40.7128,
      longitude: -74.006,
    },
  })
  .openapi("Post");
