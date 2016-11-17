#! /usr/bin/python3

import json
import sys

try:
    from pathlib import Path
except ImportError:
    print("ERROR: This script requires pathlib (Python 3.4 or later)", file=sys.stderr)
    sys.exit(1)

for p in Path.cwd().rglob("*.json"):
    print(str(p))
    try:
        with open(p, 'rb') as f:
            json.load(f)
    except Exception as ex:
        print('ERROR: ', ex, file=sys.stderr)
