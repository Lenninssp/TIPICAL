import { integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const CommentTable = sqliteTable("comments", {
  id: text("id").primaryKey(),
  postId: text("postId").notNull(),
  userId: text("userId").notNull(),
  comment: text("comment").notNull(),
  hidden: integer("hidden", { mode: "boolean" }).notNull().default(false),
  creationDate: integer("creationDate").notNull(),
  editionDate: integer("editionDate").notNull(),
});