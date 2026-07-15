import { db, schema } from "@/utils/db";

import { UserModel } from "./model";

export abstract class UserService {
  static list() {
    return db.select().from(schema.usersTable);
  }

  static create(data: UserModel.CreateUserBody) {
    return db.insert(schema.usersTable).values(data).returning();
  }
}
