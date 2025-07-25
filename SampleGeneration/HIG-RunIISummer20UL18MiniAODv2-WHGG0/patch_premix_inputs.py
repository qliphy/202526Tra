#!/usr/bin/env python3

import os
import sys
if len(sys.argv) == 1:
    print(f'Usage: {os.path.basename(sys.argv[0])} <cfgpath>', file=sys.stderr)
    exit(1)
CFGPATH = sys.argv[1]
PATCH = sys.argv[2] if len(sys.argv) > 2 else None

with open(CFGPATH) as cfgfile:
    lines = cfgfile.readlines()
for i, line in enumerate(lines):
    if line.startswith('process.mixData.input.fileNames = cms.untracked.vstring(') and line.endswith(')\n'):
        if PATCH:
            lines[i] = open(PATCH).read()
        else:
            filenames = eval(line[line.index('(') + 1:-2], { })
            keepnames = [ ]
            nskip = 0
            for j, filename in enumerate(filenames):
                if j % 100 == 0: print(f'Checking file {j}/{len(filenames)} ({nskip} skipped)')
                if os.path.exists('/eos/cms' + filename):
                    keepnames.append(filename)
                else:
                    nskip += 1
            print(f'Total skipped {nskip}/{len(filenames)}')
            lines[i] = 'process.mixData.input.fileNames = cms.untracked.vstring(' + repr(keepnames) + ')\n'
with open(CFGPATH, 'w') as cfgfile:
    for line in lines: cfgfile.write(line)
