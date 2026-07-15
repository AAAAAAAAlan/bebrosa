import { z } from "zod";

export namespace UserModel {
  export const createUserBody = z.object({
    name: z.string().trim().min(1),
    age: z.number().int().nonnegative(),
    email: z.email(),
  });

  export type CreateUserBody = z.infer<typeof createUserBody>;
}
