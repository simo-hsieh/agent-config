#!/bin/sh
# agy skips a hook that fails, which would let the call through, so any parse
# error denies. `browser` is agy's only way to drive a browser; every other
# subagent type, and any call that mixes in one, is denied.
exec python3 -c '
import json, sys

DENY = {"decision": "deny", "reason": "agy subagents are disabled except TypeName browser; delegate through Herdr instead."}

def type_names(args):
    entries = args.get("Subagents", [args])
    return [entry.get("TypeName") for entry in entries]

try:
    call = json.load(sys.stdin)["toolCall"]
    names = type_names(call["args"]) if call["name"] == "invoke_subagent" else []
    allowed = bool(names) and all(name == "browser" for name in names)
except (ValueError, KeyError, TypeError, AttributeError):
    allowed = False
print(json.dumps({} if allowed else DENY))
'
