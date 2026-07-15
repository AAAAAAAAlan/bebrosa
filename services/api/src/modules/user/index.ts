import { Elysia } from "elysia";

import { UserModel } from "./model";
import { UserService } from "./service";

export const userModule = new Elysia({
  name: "user-module",
  prefix: "/users",
})
  .get("/", () => UserService.list())
  .post("/", ({ body }) => UserService.create(body), {
    body: UserModel.createUserBody,
  });
