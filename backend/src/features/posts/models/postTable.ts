import { integer, real, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const PostTable = sqliteTable('posts', {
  id: text('id').primaryKey(),
  title: text('title').notNull(),
  description: text('description'),
  createdAt: integer()
    .notNull(),
  editedAt: integer()
    .notNull(),
  ownerId: text('userId').notNull(),
  archived: integer('archived', { mode: 'boolean' }).notNull().default(false),
  latitude: real('latitude'),
  longitude: real('longitude'),
});