import { integer, real, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const PostTable = sqliteTable('posts', {
  id: text('id').primaryKey(),
  title: text('title').notNull(),
  description: text('description'),
  createdAt: integer('createdAt', { mode: 'timestamp' })
    .notNull()
    .$defaultFn(() => new Date()),
  editedAt: integer('editedAt', { mode: 'timestamp' })
    .notNull()
    .$defaultFn(() => new Date()),
  ownerId: text('userId').notNull(),
  archived: integer('archived', { mode: 'boolean' }).notNull().default(false),
  latitude: real('latitude'),
  longitude: real('longitude'),
});