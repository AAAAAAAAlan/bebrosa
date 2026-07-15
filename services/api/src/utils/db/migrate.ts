import { migrate } from "drizzle-orm/bun-sqlite/migrator";

import { db } from "@/utils/db";

const result = migrate(db, { migrationsFolder: "./src/utils/db/migrations" });

if (result) {
  throw new Error(`Migration initialization failed: ${result.exitCode}`);
}

console.log("Database migrations applied.");
