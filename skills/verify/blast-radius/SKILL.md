---
name: blast-radius
description: Finds what a change breaks somewhere else before it ships, and proves the one fact its safety rests on. Use for "what could this break", "blast radius of X", or a small diff you don't trust yet.
---

# Blast radius

Listing callers is not the job; grep does that. Find the breakage grep won't show, and prove the fact the change is safe because of.

1. **Read the change**: the diff, the symbols it adds, changes, and deletes, and what it now does differently, including what the diff doesn't spell out. Use `why` for its history.
2. **Find the one safety fact**, such as "this call only drops already-dead cache entries". If it holds, most risky cases clear at once.
3. **Look where grep stops**: the library source at its pinned version and local patches; when things run (microtasks, teardown); JSON an API returns, DB columns, wire formats, other languages reading the same bytes, feature flags, code three hops downstream.
4. **Rate each risk** by real likelihood and cost. Cite `file:line`; never invent a caller or API; a search that finds nothing is an answer.
5. **Prove the safety fact** with a script or test that calls the real code, and paste what happened.

Take each fact as far down this ladder as is cheap, and say where it stopped: you said so; you cited the line; you walked the failure and it can't reach; you ran it; you reproduced it in the running app.

**Report:** what it does; the safety fact, its ladder step, and the proof (or "unproven"); risks with `file:line`, likelihood, cost, and how to check; what you checked and cleared; the cheapest test or repro to run before merge.
