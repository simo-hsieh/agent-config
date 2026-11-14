# Intent: run agents in a VM by default

Status: draft; awaiting my approval of the design and the open decisions in `design.md`.

## Problem

Every harness (Claude Code, Pi, Codex, agy, Hermes) runs on the Mac as my user, with my logged-in browsers, Keychain, SSH keys, and local services in reach. Approval prompts and command deny lists do not contain a prompt-injected agent. Hermes will take messages from me and from trusted family over Telegram, so text I did not write will drive agents.

## Desired outcome

1. The VM is the default place for agent work. Herdr tabs open a shell in the VM unless I choose the Mac for that tab.
2. I can still run an agent on the Mac when I develop the agent setup itself.
3. The VM and the Mac share one code folder; nothing else from the Mac is visible in the VM.
4. Hermes runs inside the VM, with a stricter container per trust level.
5. Actions on my accounts (booking, paying, sending mail, editing calendars) happen only on the Mac, after my approval.

## Constraints

- The VM is the existing isolated OrbStack machine `cloudtop`, set up like my work cloudtop: the same harnesses, installed by the same `_agent/install.sh`.
- Claude Code on Opus stays the orchestrator (`harnesses/design.md` R6).
- Model credentials inside the VM are the only account credentials there.

## Success criteria

- From the VM, no port on the Mac or the LAN is reachable, and the public internet is.
- An agent in the VM cannot regain host or LAN access (no sudo, no Docker root).
- A Herdr tab can be opened in the VM or on the Mac with one command.
- A Telegram message from a family member reaches only the `home-trusted` profile, which has no terminal, code execution, browser, or session search.
