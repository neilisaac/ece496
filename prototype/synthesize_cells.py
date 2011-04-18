#!/usr/bin/env python2

import sys
import optparse
import random

parser = optparse.OptionParser()

parser.add_option("-v", "--verilog", action="store", type="string",
		dest="filename", default="mutated_individual.v",
		help="output verilog file name")

parser.add_option("-m", "--module", action="store", type="string",
		dest="module", default="mutated_individual", help="verilog module name")

parser.add_option("-i", "--input", action="store", type="string",
		dest="input", default="in", help="input signal")

parser.add_option("-o", "--output", action="store", type="string",
		dest="output", default="out", help="output signal")

parser.add_option("-f", "--csv", action="store", type="string",
		dest="csv", default=None, help="store configuration to specified CSV file")

parser.add_option("-c", "--cells", action="store", type="int",
		dest="cells", default=10, help="number of LEs")

parser.add_option("-p", "--place", action="store", type="string",
		dest="place", default=None,
		help="enable fixed placement and set output file")

parser.add_option("-l", "--labs", action="store", type="string",
		dest="luts", default="0",
		help="comma-separated list of LUT numbers to use in each LAB")

parser.add_option("-x", "--min-x", action="store", type="int",
		dest="minx", default=1, help="starting x LAB")
		
parser.add_option("-y", "--min-y", action="store", type="int",
		dest="miny", default=1, help="starting y LAB")
		
parser.add_option("-X", "--max-x", action="store", type="int",
		dest="maxx", default=16, help="maximum x LAB")

parser.add_option("-s", "--seed", action="store", type="string",
		dest="seed", default=None, help="seed CSV file")

parser.add_option("-k", "--keep", action="store", type="int",
		dest="keep", default=0, help="number of LE functions to keep")

(options, args) = parser.parse_args(sys.argv)

if len(args) > 1:
	print "invalid arguments: " + " ".join(args[1:])
	sys.exit(1)

if options.seed is not None:
	print "--seed is not implemented"
	sys.exit(1)

if options.keep is not 0:
	print "--keep is not implemented"
	sys.exit(1)

if options.cells <= 0:
	print "--cells must be at least 1"
	sys.exit(1)

verilog = open(options.filename, "w")

# convert LUT string to integer list
options.luts = [int(l) for l in options.luts.split(",")]
options.luts.sort(reverse=True)

place = False
if options.place is not None:
	place = open(options.place, "a+")

csv = False
if options.csv is not None:
	csv = open(options.csv, "w")

# create module
print >>verilog, "module %s (" % options.module
print >>verilog, "\t%s," % options.input
print >>verilog, "\t%s\n);\n" % options.output

print >>verilog, "input %s;" % options.input
print >>verilog, "output %s;\n" % options.output

# define names for all wires that can drive a value
outputs = ["vdd", "gnd"] + ["table_%04d_out" % i for i in range(options.cells)]
for wire in outputs:
	print >>verilog, "(* keep *) wire %s;" % wire

# the module's input can also drive cell inputs
outputs.append(options.input)

# set values for vdd and gnd
print >>verilog, "\nassign vdd = 1'b1;"
print >>verilog, "assign gnd = 1'b0;\n"

# connect the output of cell 0 to the module's output
print >>verilog, "assign %s = table_0000_out;\n" % options.output

# keep set of used outputs
used = set()

# create the lookup tables
x = options.minx
y = options.miny
for i in range(options.cells):
	# instantiate module
	name = "table_%04d" % i
	print >>verilog, "\n\ncycloneii_lcell_comb %s (" % name

	data = list()

	# create input wires with randomly assigned drivers
	for letter in ["a", "b", "c", "d"]:
		wire = random.choice(outputs)
		print >>verilog, "\t.data%s(%s)," % (letter, wire)
		used.add(wire)
		data.append(wire)

	# assign module output
	print >>verilog, "\t.combout(%s_out) );\n" % name;

	# set the module's function
	mask = random.randint(0x0000, 0xFFFF)
	print >>verilog, "defparam %s .lut_mask = \"%04X\";" % (name, mask)

	## not sure what assigning .sum_lutc_input gives
	#print >>verilog, "defparam %s .sum_lutc_input = \"cin\";" % name

	# fix placement
	n = options.luts[i % len(options.luts)]
	if place:
		print >>verilog, "/* placment assigned to LCCOMB_X%d_Y%d_N%d */" % (x, y, n)
		print >>place, "set_location_assignment LCCOMB_X%d_Y%d_N%d -to %s_out" % (x, y, n, name)
		if i % len(options.luts) == len(options.luts) - 1:
			x += 1
			if x > options.maxx:
				x = options.minx
				y += 1

	# save LUT to CSV
	if csv:
		print >>csv, "%s,%s,%s,%s,%s,%s_out,%04X,%d,%d,%d" % (name,
				data[0], data[1], data[2], data[3], name, mask, x, y, n)

# make sure the input signals are assigned
if options.input not in used:
	print "ERROR: input signal %s was not used!" % options.input
	sys.exit(2)

# check for unused output signals that would otherwise get synthesized out
unused = set(outputs).difference(used)
if len(unused) > 0:
	print "WARNING: %d unused signals: %s" % (len(unused), " ".join(unused))

# end of module
print >>verilog, "\n\nendmodule\n"

# close files
verilog.close()
if csv:
	csv.close()
if place:
	place.close()

print "created module: %s" % options.module
print "saved to file: %s" % options.filename

