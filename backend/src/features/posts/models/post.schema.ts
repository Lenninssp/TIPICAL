import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { PostTable } from "./post.table";
import z from "zod";

export const SelectPostSchema = createSelectSchema(PostTable);

const BasePostInputSchema = createInsertSchema(PostTable, {
  title: z.string().min(1).trim(),
  description: z.string().min(1),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  imageUrl: z.string().optional(),
  imagePath: z.string().optional(),
}).omit({
  id: true,
  ownerId: true,
  createdAt: true,
  editedAt: true,
  archived: true,
});

const coordinateRefinement = (data: { latitude?: number; longitude?: number }) =>
  (data.latitude === undefined) === (data.longitude === undefined);

const coordinateRefinementError = {
  message: "Both latitude and longitude must be provided together, or both must be omitted.",
  path: ["latitude"],
};

export const CreatePostSchema = BasePostInputSchema.refine(
  coordinateRefinement,
  coordinateRefinementError,
);

export const UpdatePostSchema = BasePostInputSchema.partial().refine(
  coordinateRefinement,
  coordinateRefinementError,
);

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
      imageUrl: "https://example.com/image.jpg",
      imagePath: "posts/image123.jpg",
    },
  })
  .openapi("Post");
