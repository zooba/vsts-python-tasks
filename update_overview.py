#! python3.6

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OVERVIEW_IN = ROOT / 'overview.md.in'
OVERVIEW = ROOT / 'overview.md'


def get_doc(p):
    with open(p, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data['helpMarkDown']

with open(OVERVIEW_IN, 'r', encoding='utf-8') as f1:
    with open(OVERVIEW, 'w', encoding='utf-8') as f2:
        for line in f1:
            if line.startswith('!'):
                print(get_doc(ROOT / line[1:].strip()), file=f2)
            else:
                print(line, file=f2, end='')

