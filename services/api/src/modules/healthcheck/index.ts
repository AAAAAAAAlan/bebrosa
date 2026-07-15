import { Elysia } from "elysia";

export const healthcheckModule = new Elysia({
  name: "healthcheck-module",
}).get("/", () => ({ status: "ok" as const }));
