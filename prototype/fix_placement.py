#!/usr/bin/env python2

import sys
import optparse
import random
import re

parser = optparse.OptionParser()
		
parser.add_option("-i", "--instance-patterns", action="store", type="string",
		dest="instpat", default="table",
		help="instance patterns to match")
		
parser.add_option("-c", "--cell", action="store", type="string",
		dest="cell", default="cycloneii_lcell_comb",
		help="module name to look for")

parser.add_option("-x", "--min-x", action="store", type="int",
		dest="minx", default=1, help="starting x cell")
		
parser.add_option("-y", "--min-y", action="store", type="int",
		dest="miny", default=1, help="starting y cell")
		
parser.add_option("-X", "--max-x", action="store", type="int",
		dest="maxx", default=16, help="maximum x cell")
		
parser.add_option("-l", "--luts-per-lab", action="store", type="int",
		dest="luts", default=1, help="number of LUTs to use per LAB")

parser.add_option("-f", "--fix-luts", action="store_true",
		dest="fixluts", help="fix the specific LUT in a LAB")
		
(options, args) = parser.parse_args(sys.argv)


# complain about wrong args
if len(args) != 3:
	print "usage: %s input.vqm output.qsf" % args[0]
	print "unknown arguments: " + " ".join(args[1:])
	sys.exit(1)

filename = args[1]
output = args[2]
patterns = options.instpat.split(",")

# simple and awful parser used to get instance names matching cell and name
instances = list()
f = open(filename, "r")
for line in f.readlines():
	if line.find("//") < 0 and re.search("%s (.*) \(" % options.cell, line):
		name = line.split()[1]
		for pattern in patterns:
			if name.find(pattern) >= 0:
				instances.append(name)
				break
			
f.close()


# use more deterministic processing order
instances.sort()


# write out fixed placements
f = open(output, "a+")
x = options.minx
y = options.miny
for i in range(len(instances)):
	name = re.sub(r'[_~]I$', '', re.sub(r'^\\', '', instances[i]))
	if options.fixluts:
		n = (i % options.luts) * 2
		print >>f, "set_location_assignment LCCOMB_X%d_Y%d_N%d -to %s" % (x, y, n, name)
	else:
		print >>f, "set_location_assignment LAB_X%d_Y%d -to \"%s\"" % (x, y, name)
	
	if i % options.luts == options.luts - 1:
		x += 1
		if x > options.maxx:
			x = options.minx
			y += 1

f.close()

