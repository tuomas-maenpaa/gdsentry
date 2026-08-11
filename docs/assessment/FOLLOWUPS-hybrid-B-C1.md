# Follow-ups: hybrid B+C1 spine

Tracked deferrals after FRC on `main` (`a9477a3` merge of PR #1) and baseline docs align.

| ID | Item | Status | Notes |
|----|------|--------|-------|
| F1 | Mass rewrite of hardcoded `res://gdsentry/` / `res://base_classes/` in self-tests (~90 hits) | **Deferred** | Core loaders use `framework_paths`; tests still often hardcode. Do after `gdsentry-tdd` skill exists. |
| F2 | `test_runner` fresh-project `class_name` / global class cache smoke | **Deferred** | Non-blocking for harness `framework_paths` path; track separately. |
| F3 | Coverage thin tool (`tools/coverage/`) cherry-pick from WIP | **Parked** | Gate 4 default: park until spine feels boring. Vault: `origin/wip/coverage-restructure`. |
| F4 | `src/` layout relocation epic | **Out of spine** | Separate epic only if packaging needs it; still no Typer CLI. |
| F5 | Quill submodule pin + `project.godot` | Gate 5 | Explicit handoff after spine. |

Happy-path command (agents/docs):

```bash
./gdsentry-self-test/gdsentry-self-test.sh --category core --pattern "*framework_paths*" --verbose
```

CI on `main` already runs `./gdsentry-self-test/gdsentry-self-test.sh` (Godot harness) — not a Python CLI.
