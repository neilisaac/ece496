#!/usr/bin/env python2

import sys
import re

patterns = [
		"truncated value with size 32 to match size of target",
		"Input port expression \(32 bits\) is wider than the input port",
		"No output dependant on input pin",
		"Pin \".*\" is stuck at [VDGN].*",
		"No output dependent on input pin",
		"Design contains .* input pin\(s\) that do not drive logic",
		"Output pins are stuck at VCC or GND",
		"hierarchies have connectivity warnings - see the Connectivity Checks report folder",
		"Declared by entity but not connected by instance",
	]

name = "evolution.map.rpt"
if len(sys.argv) > 1:
	name = sys.argv[1]

f = open(name, "r")

errors = 0

for line in f.readlines():

	if line.find("Warning") < 0:
		continue
	
	for pat in patterns:
		if re.search(pat, line) is not None:
			break	
	else:
		print line,
		errors += 1

if errors > 0:
	sys.stderr.write("%d unacceptable warning(s) in synthesis\n" % errors)

sys.exit(errors)

