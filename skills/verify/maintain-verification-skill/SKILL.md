---
name: maintain-verification-skill
description: Keeps a project-local verification skill and its feature map true to the app, from source and from live drives. Use for /maintain-verification-skill.
disable-model-invocation: true
---

# Maintain a verification skill

Outcome, stated up front in the report: **clean** (every feature covered from source and live; no change), **changed** (one change with proven doc, harness, or map fixes), or **blocked** (say exactly what blocked it).

Edit only the verification skill's own directory. A behavior the map describes that the app no longer does is doc drift (fix the map) or a product regression (report it; don't paper over it).

1. **Locate** the project's verification skill (launch and drive sections plus a feature map). Several: ask which. None: point at `/create-verification-skill`.
2. **Index hygiene**: fix missing, extra, duplicate, or dead entries in the feature map.
3. **Source pass**: one read-only subagent per feature file explains how the feature works from source, flags drift with citations, and returns one live recipe. It never drives the app or edits files.
4. **Reconcile**: merge recipes into as few app states as practical; spot-check cited drift; require a concrete source path before calling a surface missing from the map.
5. **Live pass**, required even when source looks clean: you drive, following the skill's launch model. Exercise every feature once. Run doctor before the first drive and after anything surprising. Keep captured evidence through every cleanup. Clean up whatever a drive started. A feature is unreachable only with its concrete prerequisite named.
6. **Triage**: wrong description is doc drift (fix it); working behavior the harness can't drive is a harness gap (fix it, then re-drive); broken app behavior is a product gap (report it, keep it out of this change).
7. **Ship or stop**: for changed, one jj change of proven corrections. Keep run notes in scratch, uncommitted.
