#!/usr/bin/env python3
"""Reuse the bounded raw decoder for one separate no-Z G93 control."""
import importlib.util
import json
from pathlib import Path
import sys

spec = importlib.util.spec_from_file_location('bounded', Path(__file__).with_name('bounded.py'))
bounded = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bounded)
root = Path(sys.argv[1])
text = (root/'no-z.txt').read_text()
bounded.require(text.splitlines().count('done') == 1 and 'timeout' not in text, 'no-Z complete')
groups = bounded.decode(root/'no-z.txt')
bounded.require(len(groups) == 1, 'one no-Z curve')
group = groups[0]
bounded.require(group['start'] == (0.,0.,0.) and all(p[2] == 0. for p in group['points']), 'zero Z travel')
bounded.require(group['points'][-1][:3] == (10.,0.,0.), 'no-Z endpoint')
print(json.dumps(bounded.metrics(group, 'no_z_s', 'g93'), indent=2))
