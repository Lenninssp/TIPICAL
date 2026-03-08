import type { UsersTable } from "./user.table";

export type User = typeof UsersTable.$inferSelect;