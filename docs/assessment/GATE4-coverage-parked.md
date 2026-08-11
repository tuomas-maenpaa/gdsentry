# Gate 4 decision: coverage salvage

**Date:** 2026-08-11  
**Decision:** **Park** (plan recommended default G4.1)

Spine (FRC on `main`, docs happy path, `gdsentry-tdd` skill, harness 6/6) is in place. Coverage cherry-pick from `origin/wip/coverage-restructure` into `tools/coverage/` is **not** started in this arc.

When reopening Gate 4 later:

- Defaults: HTML + terminal summary; framework self-coverage first; Conda OK; re-home to `tools/coverage/`
- Leave Typer CLI / trail / `src/` mega-move on the WIP vault
- Extend `.cursor/skills/gdsentry-tdd` with how to invoke the thin tool

See [FOLLOWUPS-hybrid-B-C1.md](./FOLLOWUPS-hybrid-B-C1.md) item F3.
