# Gate 4 decision: coverage salvage (reopened)

**Date:** 2026-08-31 (retro gate pass)  
**Decision:** **Start coverage salvage** (overrides earlier park)

## What landed

- Thin tool: [`tools/coverage/`](../../tools/coverage/) (`gdsentry_coverage` package + `run_coverage.py` argparse)  
- Design pointers: [`coverage-refs/`](./coverage-refs/)  
- Not included: Typer CLI, Podman, `gdsentry.toml` platform, WIP mega-merge  

## Defaults used

| Item | Choice |
|------|--------|
| Output | Terminal summary + HTML |
| Target first | Framework / instrument path (self-coverage oriented) |
| Python | Stdlib + Conda OK |
| Path | `tools/coverage/` |

## Known limits

- Instrumented project prepare is thin (not full copytree)  
- GDScript HTML reporter shipped but not always auto-invoked  
- Full Godot coverage loop may need iteration — treat as v0 sidecar  

See [FOLLOWUPS-hybrid-B-C1.md](./FOLLOWUPS-hybrid-B-C1.md).
