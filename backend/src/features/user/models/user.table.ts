import { integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const UsersTable = sqliteTable('users', {
  id: text('id')
    .primaryKey(),
  description: text('descripition'),
  firstName:  text('firstName'),
  lastName: text('lastName'),
  profilePicture: text('profilePicture'),
  birthDate: integer('birthDate', { mode: 'timestamp' })
    .$defaultFn(() => new Date()),
  creationDate: integer('creationDate', { mode: 'timestamp'})
    .$defaultFn(() => new Date())
})