import type { PostTable } from "./post.table";

export type Post = typeof PostTable.$inferSelect;