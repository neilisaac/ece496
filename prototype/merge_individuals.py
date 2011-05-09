#!/usr/bin/env python2

import sys
import random
import optparse

parser = optparse.OptionParser()

parser.usage = "%prog [options] input1.csv input2.csv [output.csv]"

options, args = parser.parse_args(sys.argv)

if not (3 <= len(args) <= 4):
	parser.print_help()
	sys.exit(1)

input1 = args[1]
input2 = args[2]
output = None
if len(args) == 4:
	output = args[3]

out = sys.stdout
std = sys.stderr
if output is not None:
	out = open(output, 'w')
	std = sys.stdout

count = [0, 0]
for lines in zip(open(input1).readlines(), open(input2).readlines()):
	pick = random.randint(0, 1)
	count[pick] += 1
	print >> out, lines[pick],

if output is not None:
	print >> std, "%s:" % output,

print >> std, "%d lines from %s and %d from %s" % \
		(count[0], input1, count[1], input2)

