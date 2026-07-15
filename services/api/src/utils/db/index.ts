import { defineRelations } from "drizzle-orm";
import { drizzle } from "drizzle-orm/bun-sqlite";

import * as authSchema from "@/utils/db/schema/auth";
import * as userSchema from "@/utils/db/schema/user";

export const schema = {
  ...authSchema,
  ...userSchema,
};

const databaseFile = process.env.DB_FILE_NAME ?? "local.sqlite";
const relations = defineRelations(schema);

export const db = drizzle(databaseFile, { relations });
