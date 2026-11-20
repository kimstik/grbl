#!/usr/bin/env python3
"""Render one comparison corpus without changing its XY words."""
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("source", type=Path)
parser.add_argument("output", type=Path)
parser.add_argument("--mode", choices=("G94", "G93"), default="G94")
parser.add_argument("--z", action="store_true", help="add the same Z-3 word to each curve")
args = parser.parse_args()
text = args.source.read_text(encoding="utf-8")
for key, value in (("@MODE@", args.mode), ("@Z@", "Z-3" if args.z else ""),
                   ("@F@", "2" if args.mode == "G93" else "1000")):
    text = text.replace(key, value)
for line in text.splitlines():
    if line and not line.startswith("#") and len(line) >= 80:
        parser.error(f"line does not fit LINE_BUFFER_SIZE=80: {line}")
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(text, encoding="utf-8")
