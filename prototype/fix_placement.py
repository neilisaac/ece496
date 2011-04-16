#!/usr/bin/env python2

import sys
import optparse
import random
import re

parser = optparse.OptionParser()

parser.add_option("-f", "--file", action="store", type="string",
		dest="filename", default=None,
		help="input vqm file")
		
parser.add_option("-o", "--output", action="store", type="string",
		dest="output", default="output.qsf",
		help="output project file to append to")
		
parser.add_option("-n", "--name", action="store", type="string",
		dest="name", default="table",
		help="name used to match instacnes")
		
parser.add_option("-c", "--cell", action="store", type="string",
		dest="cell", default="cycloneii_lcell_comb",
		help="module name to look for")

parser.add_option("-x", "--min-x", action="store", type="int",
		dest="minx", default=30,
		help="starting x cell")
		
parser.add_option("-y", "--min-y", action="store", type="int",
		dest="miny", default=30, 
		help="starting y cell")
		
parser.add_option("-Y", "--max-y", action="store", type="int",
		dest="maxy", default=40, 
		help="starting y cell")
		
parser.add_option("-v", "--n-values", action="store", type="string",
		dest="nvalues", default="2,4",
		help="valid values for n (comma separated)")
		
(options, args) = parser.parse_args(sys.argv)


# file name is required
if options.filename is None:
	print "--file is unspecified"
	sys.exit(1)

# complain about extra args
if len(args) > 1:
	print "unknown arguments: " + " ".join(args[1:])


# parse valid n values
nvalues = sorted([int(n) for n in options.nvalues.split(",")])


# simple and awful parser used to get instance names matching cell and name
instances = list()
f = open(options.filename, "r")
for line in f.readlines():
	if line.find("//") < 0 and re.search("%s (.*) \(" % options.cell, line):
		name = line.split()[1]
		if name.find(options.name) >= 0:
			instances.append(name)
			
f.close()


# use more deterministic processing order
instances.sort()


# write out fixed placements
f = open(options.output, "a+")
x = options.minx
y = options.miny
for i in range(len(instances)):
	name = instances[i]
	n = nvalues[i % len(nvalues)]
	print >>f, "set_location_assignment LCCOMB_X%d_Y%d_N%d -to %s" % (x, y, n, name)
	
	if i % len(nvalues) == len(nvalues) - 1:
		y += 1
		if y == options.maxy:
			y = options.miny
			x += 1

f.close()

