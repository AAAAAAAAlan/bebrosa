import { Elysia } from "elysia";

import { auth } from "@/utils/auth";

export const authModule = new Elysia({ name: "auth-module" }).mount(
  auth.handler,
);
