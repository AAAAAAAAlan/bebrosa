import { Elysia } from "elysia";

import { authModule } from "@api/modules/auth";
import { healthcheckModule } from "@api/modules/healthcheck";
import { userModule } from "@api/modules/user";

export const app = new Elysia()
  .use(authModule)
  .use(healthcheckModule)
  .use(userModule)
  .listen(Number(process.env.PORT ?? 3000));

console.log(
  `Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);

export type App = typeof app;
