---
name: happinessmp-dev
description: Build, explain, review, and troubleshoot HappinessMP projects using a bundled snapshot of the official documentation. Use for HappinessMP client or dedicated-server setup, settings.xml and console commands, Lua or Squirrel resources and meta.xml files, addons and streaming assets, client/server events and exports, WebUI integration, API function lookup, or GTA IV model, key, weapon, animation, HUD, blip, checkpoint, weather, ped, and vehicle identifiers.
---

# HappinessMP Developer

Use the official documentation snapshot in `references/` as the source of truth. Support server operators and developers without inventing APIs, parameters, execution contexts, identifiers, or defaults.

Resolve every relative reference path from the directory containing this `SKILL.md`, regardless of the agent's current working directory.

## Work accurately

1. Identify whether the task concerns installation, server administration, scripting structure, an API family, WebUI, an addon, or a game identifier.
2. Read only the relevant reference files from the routing table below. Search large references before loading broad sections.
3. Confirm every named HappinessMP function against its API table. Preserve its documented capitalization, execution context (`Client`, `Server`, or both), parameters, return type, and language-specific examples.
4. Distinguish client, server, and shared scripts. Do not move trusted server behavior or secrets into client-delivered code.
5. Follow the documented `meta.xml`, `settings.xml`, resource, addon, event, export, and WebUI conventions exactly.
6. State when the documentation does not define a requested behavior. Do not substitute an API from another multiplayer framework.
7. Cite the official page URL included in each reference when answering factual questions or explaining a non-obvious constraint.

## Route to references

| Task | Read |
| --- | --- |
| Project overview or homepage links | `references/project-overview.md` |
| Client setup, crash-report privacy, server install, console commands, or `settings.xml` | `references/setup-and-server.md` |
| Resources, addons, `meta.xml`, events, exports, or WebUI concepts | `references/scripting-guides.md` |
| Chat, console, events, resource, server, or session functions | `references/api-core.md` |
| Database, HTTP, text, thread, or timer functions | `references/api-services.md` |
| Game, player, or WebUI functions | `references/api-gameplay.md` |
| Animations, blips, checkpoints, HUD, keys, MLOs, ped bones, vehicle colors, weapons, or weather | `references/game-reference.md` |
| Pedestrian or vehicle model identifiers, including TLAD and TBOGT | `references/game-models.md` |
| Community guidelines, server-operator policy, or terms | `references/policies.md` |
| Releases, update history, tags, archive, or authors | `references/release-history.md` |
| Completeness check or locating the reference that contains a sitemap page | `references/source-index.md` |

For large identifier tables, search first. Examples:

```text
rg -n -i "police|ambulance" references/game-models.md
rg -n -i "weather|sunny|rain" references/game-reference.md
rg -n -i "SetPosition|GetPosition" references/api-*.md
```

If `rg` is unavailable, use the host's equivalent text-search command.

## Build or modify code

- Inspect the user's repository and its local conventions before creating files.
- Choose Lua or Squirrel from the existing resource or the user's request; do not silently mix languages.
- Define resource scripts, exports, and raw files in `meta.xml` using documented element names and `client`, `server`, or `shared` types.
- Treat WebUI as an on-demand CEF interface. Manage creation, events, focus, input, and destruction using the documented APIs.
- Keep event names and export names consistent between producers and consumers.
- Use documented glob support only where the resource or addon guide permits it.
- For addons, keep streamable assets in the `stream` folder and definition/content files in the addon root as documented.
- Validate XML syntax, file paths, script context, API names, and argument order after editing.
- Explain any assumption that is not specified by the official references.

## Diagnose failures

Check these in order:

1. File and folder placement.
2. `meta.xml` or `settings.xml` syntax and referenced paths.
3. Lua versus Squirrel resource type.
4. Client/server/shared execution context.
5. Exact event, export, and API names.
6. Parameter types, argument order, and return-value handling.
7. Resource lifecycle, WebUI focus/lifecycle, or addon streaming requirements.
8. Server console output and relevant client logs supplied by the user.

Give the smallest evidence-backed fix. Avoid broad rewrites unless the user asks for one.

## Handle freshness

The bundled references were fetched from all 69 URLs in `https://happinessmp.net/sitemap.xml` on 2026-07-12. When the user asks about a newer release, current download version, changed policy, or recently added API, fetch the relevant official HappinessMP page and label any difference from the bundled snapshot.
