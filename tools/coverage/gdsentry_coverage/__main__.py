"""Allow: PYTHONPATH=tools/coverage python -m gdsentry_coverage …"""

import runpy
from pathlib import Path

if __name__ == "__main__":
    runpy.run_path(str(Path(__file__).resolve().parent.parent / "run_coverage.py"), run_name="__main__")
