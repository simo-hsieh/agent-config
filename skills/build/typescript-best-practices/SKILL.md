---
name: typescript-best-practices
description: Type-level rules for writing or reviewing TypeScript. Use whenever writing TypeScript; project conventions override these.
---

# TypeScript best practices

| Rule | Do |
|---|---|
| Discriminated unions | Model variants with a `kind` literal so impossible states can't be built. No bags of optional fields. |
| Branded types | Brand semantic primitives (`string & { readonly __brand: "UserId" }`). A brand comes from a type guard that verifies it, never from `as`. |
| Constructive types | Make the illegal value unconstructible: `[T, ...T[]]` for non-empty, `start` plus `duration` for a range. |
| Simplest total type | Keep `T[]` while every operation stays total; strengthen only where the loose type forces `!`, a cast, or a "can't happen" throw. |
| `unknown` over `any` | External data is `unknown` until parsed. |
| Schemas before guards | Use the repo's runtime schema library and infer the type (`z.infer`) before hand-writing a guard. |
| No `as` | Cast only after validation. Prefer `satisfies`, which checks without widening. |
| Narrowing order | Discriminant switch, then `in`, then `typeof`/`instanceof`, then a type guard, then `as`. |
| Honest guards | A guard named `isX`/`hasX` must verify the claim. |
| Exhaustiveness | `const _exhaustive: never = x;` in the default arm. |
| Boundary parsing | Parse into a named domain type where data enters; `Record<string, unknown>` stops there. |
| Derived types | Reach for `Pick`, `Omit`, `Parameters`, `ReturnType`, `Awaited`, `typeof` before a new interface. |
| Object arguments | Pass an object, not positional arguments, except on hot paths. |
| Real tests | Run the real thing; mock only what can't run locally. |
| Telemetry | Structured logger with an id for context; no `console.log` in shipped code. |
