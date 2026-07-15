# HappinessMP API

Elysia API running on Bun, with Zod validation and Drizzle ORM backed by
`bun:sqlite`.

## Development

Install workspace dependencies from the repository root:

```bash
bun install
```

Copy `.env.example` to `.env` if you want to override the default
`local.sqlite` database path. Configure `BETTER_AUTH_SECRET`, the Discord OAuth
credentials, and (optionally) comma-separated Better Auth user IDs in
`ADMIN_USER_IDS`, then apply the schema and start the API:

```bash
bun run db:push
bun run dev
```

The server listens on <http://localhost:3000>.

## Authentication

Better Auth 1.7 is mounted at `/api/auth/*`. Discord is the only enabled sign-in
provider. Configure the Discord application's OAuth redirect URI as
`http://localhost:3000/api/auth/callback/discord` for local development.

Start a Discord login with `POST /api/auth/sign-in/social` and a JSON body of
`{"provider":"discord"}`. Better Auth's admin plugin endpoints are available
under `/api/auth/admin/*` and require an authenticated user whose role is
`admin` or whose Better Auth user ID appears in `ADMIN_USER_IDS`.

Discord phone-only accounts may not expose an email address. Those users receive
an internal `<discord-id>@discord.placeholder.local` address; it must not be
used for email delivery.

## Commands

- `bun run typecheck` validates the TypeScript project without emitting files.
- `bun run db:generate` generates SQL migrations in `src/utils/db/migrations/`.
- `bun run db:migrate` applies generated migrations with Drizzle's Bun SQLite migrator.
- `bun run db:push` pushes the current schema directly to the local database.
- `bun run db:studio` opens Drizzle Studio.

Request schemas are regular Zod schemas passed directly to Elysia route
options through Elysia's Standard Schema support.
