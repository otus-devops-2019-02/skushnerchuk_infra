#!/usr/bin/env python3

import os 


lines = ''
path = os.path.dirname(__file__)
path = os.path.join(path, 'inventory.json')

with open(path) as f:
    lines += f.read()
print(lines)

