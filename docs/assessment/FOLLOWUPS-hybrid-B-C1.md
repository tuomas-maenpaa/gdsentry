# Follow-ups: hybrid B+C1 spine

| ID | Item | Status | Notes |
|----|------|--------|-------|
| F1 | Mass rewrite of hardcoded `res://gdsentry/` / `res://base_classes/` in self-tests | **Deferred** | Core loaders use `framework_paths` |
| F2 | `test_runner` fresh-project `class_name` / global class cache smoke | **Deferred** | Prefer harness for spine checks |
| F3 | Coverage thin tool | **Done (v0)** | `tools/coverage/` — deepen instrumented project / GD reporter wiring later |
| F4 | `src/` layout relocation epic | **Out of spine** | |
| F5 | Quill submodule pin + `project.godot` | **Done** | Gate 5 keep |
| F6 | Skill ownership migrate | **This batch** | Methodology → `.gdsentry/.cursor/skills/`; Quill thin pointer |
| F7 | Quill sample game test | **Deferred** | Gate G5.3 = no |

Happy-path:

```bash
./gdsentry-self-test/gdsentry-self-test.sh --category core --pattern "*framework_paths*" --verbose
```

Coverage:

```bash
cd tools/coverage && python run_coverage.py --help
```
