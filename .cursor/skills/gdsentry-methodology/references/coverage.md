# Coverage (thin tool)

Sidecar under `tools/coverage/` — hybrid B+C1. Not the WIP Typer product.

## When to use

- User asks for coverage / line coverage / HTML report  
- After green tests, to see untested framework or game scripts  

## How to run

From GDSentry root:

```bash
cd tools/coverage
python run_coverage.py --help

python run_coverage.py \
  --source-root ../.. \
  --output-dir ../../.coverage_out \
  --framework-root ../.. \
  --instrument-only
```

Full Godot loop: omit `--instrument-only` and pass runner args after `--` (see README).

From Quill (nested `.gdsentry`):

```bash
cd .gdsentry/tools/coverage
python run_coverage.py \
  --source-root ../../.. \
  --framework-root ../.. \
  --output-dir ../../../.coverage_out \
  --instrument-only
```

Adjust `--source-root` to the scripts you want instrumented (framework vs game).

## Agent duties

1. Read `tools/coverage/README.md` if flags are unclear  
2. Prefer Conda env with Python 3.10+  
3. Summarize terminal % and point at HTML under the output dir  
4. Do not reintroduce `gdsentry test run` or `pip install -e .` for coverage  

## Limits (v0)

- Instrumented project prepare is thin  
- May need iteration for full Godot runs  
- Do not treat plan-2.x “COMPLETE” as fully productized UX
