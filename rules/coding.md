# Coding rules

Read before writing or reviewing code. Project conventions override these.

## Design

- Edit existing functions and classes directly. Add adapters, factories, or DTOs only when several callers need them.
- Keep logic pure and I/O (file, network, DB, RPC, UI) in thin outer layers; the core never imports the shell. This keeps tests free of mocks.
- One authoritative owner per piece of state. Compute derived state instead of caching a mirror.
- Prefer simple, readable code over clever abstraction. Do not add speculative generality.

## Naming and layout

- An identifier says exactly what it is and fits its scope and type: `is_/has_/can_` booleans, plural collections, unit suffixes (`_seconds`, `_ms`, `_bytes`).
- Avoid noise words (Data, Info, Manager, Helper, Object, Item, Handler, Processor, State, Impl, Util, Common) unless the domain uses them.
- Keep files focused: one primary symbol per file, named after it, roughly under 300 lines. Put tests beside their source and group directories by feature, not by kind (`utils/`, `helpers/`).

## Errors

- No empty handlers. Recover, propagate with context, or log at the boundary; an intentional ignore gets a comment saying why. Never log and rethrow.
- Preserve the cause (Go `%w`, Python `raise X(...) from err`, JS `{ cause }`). Catch specific errors; no bare `except` or silent fallback data.
- Handle every rejected promise and awaited error; in Kotlin rethrow `CancellationException` before a broad catch.

## Comments and tests

- Comments explain intent, constraints, or non-obvious decisions, not what the code says.
- Add or update tests when behavior changes and a useful test is practical. Prefer red-green: write the failing test, then the minimal fix.
- Do not hardcode values to satisfy tests; implement the general solution, and report a wrong test rather than working around it.
