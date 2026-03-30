import { integer, sqliteTable, text, uniqueIndex } from "drizzle-orm/sqlite-core";
import { PostTable } from "../../posts/models/post.table";
import { UsersTable } from "../../user/models/user.table";

export const LikeTable = sqliteTable("post_likes", {
  id: text("id").primaryKey(),
  postId: text("postId")
    .notNull()
    .references(() => PostTable.id, { onDelete: "cascade" }),
  userId: text("userId")
    .notNull()
    .references(() => UsersTable.id, { onDelete: "cascade" }),
  createdAt: integer("createdAt").notNull(),
}, (table) => {
  return {
    uniqueLike: uniqueIndex("unique_like_idx").on(table.postId, table.userId),
  };
});
