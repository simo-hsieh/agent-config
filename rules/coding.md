# Coding rules

Read before writing or reviewing code. Project conventions override these.

## Design

- Edit existing functions and classes directly. Add adapters, factories, or DTOs only when several callers need them. A new layer or piece of state must cut reader load elsewhere by as much; a reader should find quickly where a value comes from and what changes it.
- Encode the domain in a structure (state machine, registry, discriminated union) instead of another if-branch or a second synced boolean; see `~/.agents/skills/model-the-domain/SKILL.md`.
- Keep logic pure and I/O (file, network, DB, RPC, UI) in thin outer layers; the core never imports the shell. This keeps tests free of mocks. Parse external data (requests, files, env, DB rows) into typed domain values at the boundary and trust them inside; brand semantic IDs; derive types from the schema owner (proto, OpenAPI, migration).
- One authoritative owner per piece of state. Compute derived state instead of caching a mirror. Remove a shared write target before adding a lock.
- A state-changing operation converges from the current state, so running it twice or after a crash halfway ends the same; see `~/.agents/skills/make-operations-idempotent/SKILL.md`.
- When replacing an API you own with no external users, move every caller and delete the old one in the same change.
- The user includes the API consumer and the next maintainer; every option must earn its place.

## Naming and layout

- An identifier says exactly what it is and fits its scope and type: `is_/has_/can_` booleans, plural collections, unit suffixes (`_seconds`, `_ms`, `_bytes`).
- Avoid noise words (Data, Info, Manager, Helper, Object, Item, Handler, Processor, State, Impl, Util, Common) unless the domain uses them.
- Keep files focused: one primary symbol per file, named after it, roughly under 300 lines. Put tests beside their source and group directories by feature, not by kind (`utils/`, `helpers/`).

## Errors

- No empty handlers. Recover, propagate with context, or log at the boundary; an intentional ignore gets a comment saying why. Never log and rethrow.
- Preserve the cause (Go `%w`, Python `raise X(...) from err`, JS `{ cause }`). Catch specific errors; no bare `except` or silent fallback data.
- Handle every rejected promise and awaited error; in Kotlin rethrow `CancellationException` before a broad catch.

## Comments and tests

- Comments explain a non-obvious why the code can't show: intent, an external constraint, a decision. No narration of what the code does and no phase comments; when our own code needs a comment to stop being surprising, first try a rename or reshape that makes it obvious.
- Add or update tests when behavior changes and a useful test is practical. Prefer red-green per `~/.agents/skills/tdd/SKILL.md`.
- Do not hardcode values to satisfy tests; implement the general solution, and report a wrong test rather than working around it.
