"""Script de conveniência para rodar tudo de uma vez."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

commands = [
    [sys.executable, "src/etl/run_etl.py"],
    [sys.executable, "src/elt/run_elt.py"],
    [sys.executable, "src/quality/validate_outputs.py"],
    [sys.executable, "scripts/generate_analysis_outputs.py"],
]

for command in commands:
    print("\n$", " ".join(command))
    subprocess.run(command, cwd=ROOT, check=True)
