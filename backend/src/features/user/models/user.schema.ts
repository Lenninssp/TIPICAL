import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { UsersTable } from "./user.table";

export const UserSchema = createSelectSchema(UsersTable)
  .openapi({
    example: {
      id: "hasldkghalkjsdfa",
      username: "user",
      firstName: "Jon",
      lastName: "Doe",
      description: "Just a boring guy from cincinati",
      creationDate: "2021-01-01T00:00:00.000Z",
      birthDate: "2021-01-01T00:00:00.000Z",
    },
  })
  .openapi("User");

export const CreateUserSchema = createInsertSchema(UsersTable).openapi({
  example: {
    id: "hasldkghalkjsdfa",
    username: "user",
    firstName: "Jon",
    lastName: "Doe",
    description: "Just a boring guy from cincinati",
    creationDate: "2021-01-01T00:00:00.000Z",
    birthDate: "2021-01-01T00:00:00.000Z",
  },
});
