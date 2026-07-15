import { defineConfig } from "drizzle-kit";

export default defineConfig({
  out: "./src/utils/db/migrations",
  schema: "./src/utils/db/schema",
  dialect: "sqlite",
  dbCredentials: {
    url: process.env.DB_FILE_NAME ?? "local.sqlite",
  },
});
