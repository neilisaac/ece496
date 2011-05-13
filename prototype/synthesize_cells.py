#!/usr/bin/env python2

import sys
import optparse
import random

from cell import Cell

parser = optparse.OptionParser()

parser.add_option("--verilog", action="store", type="string",
		dest="filename", default="mutated_individual.v",
		help="output verilog file name")

parser.add_option("--module", action="store", type="string",
		dest="module", default="mutated_individual", help="verilog module name")

parser.add_option("--prefix", action="store", type="string",
		dest="prefix", default="", help="instance name prefix for top-level instanciation")

parser.add_option("--inputs", action="store", type="string",
		dest="inputs", default="in", help="input signals")

parser.add_option("--outputs", action="store", type="string",
		dest="outputs", default="out", help="output signals")

parser.add_option("--csv", action="store", type="string",
		dest="csv", default=None, help="store configuration to specified CSV file")

parser.add_option("--cells", action="store", type="int",
		dest="cells", default=10, help="number of LEs")

parser.add_option("--place", action="store", type="string",
		dest="place", default=None,
		help="enable fixed placement and set output file")

parser.add_option("--luts", action="store", type="string",
		dest="luts", default="0",
		help="comma-separated list of LUT numbers to use in each LAB")

parser.add_option("--min-x", action="store", type="int",
		dest="minx", default=1, help="starting x LAB")
		
parser.add_option("--min-y", action="store", type="int",
		dest="miny", default=1, help="starting y LAB")
		
parser.add_option("--max-x", action="store", type="int",
		dest="maxx", default=16, help="maximum x LAB")

parser.add_option("--seed", action="store", type="string",
		dest="seed", default=None, help="seed CSV file")

parser.add_option("--mutate", action="store", type="float",
		dest="mutate", default=0.05, help="fraction of cells to mutate")

parser.add_option("--tie-unused", action="store_true", dest="tieunused",
		help="add a moudle output signal to guarantee all signals are used")

(options, args) = parser.parse_args(sys.argv)

if len(args) > 1:
	print "invalid arguments: " + " ".join(args[1:])
	sys.exit(1)

if options.cells <= 0:
	print "--cells must be at least 1"
	sys.exit(1)

# convert LUT string to integer list
options.luts = [int(l) for l in options.luts.split(",")]
options.luts.sort(reverse=True)

# conver input and output strings into lists
options.inputs = options.inputs.split(",")
options.outputs = options.outputs.split(",")

verilog = open(options.filename, "w")

place = False
if options.place is not None:
	place = open(options.place, "a+")

csv = False
if options.csv is not None:
	csv = open(options.csv, "w")

# create module
print >>verilog, "module %s (" % options.module
print >>verilog, "\t%s," % ", ".join(options.inputs)
print >>verilog, "\t%s" % ", ".join(options.outputs),

if options.tieunused:
	print >>verilog, ",\n\ttie_unused",

print >>verilog, "\n);\n"

# declare inputs and outputs
for signal in options.inputs:
	print >>verilog, "input %s;" % signal

for signal in options.outputs:
	print >>verilog, "output %s;" % signal

if options.tieunused:
	print >>verilog, "output tie_unused;"

print >>verilog, ""

# defind vdd and gnd
print >>verilog, "wire vdd;"
print >>verilog, "wire gnd;"

# set values for vdd and gnd
print >>verilog, "\nassign vdd = 1'b1;"
print >>verilog, "assign gnd = 1'b0;\n"

# define names for all wires that can drive a value
outputs = ["table_%04d_out" % i for i in range(options.cells)]
for wire in outputs:
	print >>verilog, "(* keep *) wire %s;" % wire

print >>verilog, ""

# the module's input can also drive cell inputs
outputs.extend(options.inputs)

# vdd and gnd can also drive cell inputs
outputs.append("vdd")
outputs.append("gnd")

# randomly assign LUT outputs to the module's output signals
for signal in options.outputs:
	number = random.randint(0, options.cells - 1)
	print >>verilog, "assign %s = table_%04d_out;" % (signal, number)

print >>verilog, "\n"

# keep set of used outputs
used = set()

# keep a list of cells
cells = list()

# read cell descriptions from seed file
if options.seed:
	seed = open(options.seed, 'r')

	for line in seed.readlines():
		line = line.strip()
		if len(line) > 0:
			cell = Cell.readCSV(line)
			if cell is not None:
				cells.append(cell)

	seed.close()

# modify some of the cells
mutate = int(len(cells) * options.mutate)
print "mutating %d cells" % mutate
for i in range(mutate):
	cell = random.choice(cells)

	bits = random.randint(0, 16)
	cell.mutateFunction(bits)

	swaps = random.randint(0, 4)
	for j in range(swaps):
		new = random.choice(outputs)
		cell.swapInput(new)

	print "\tmodified %s: %d function bits and %d input swaps" % (str(cell), bits, swaps)

# find nets already used as inputs
for cell in cells:
	for net in cell.inputs:
		used.add(net)

# create the lookup tables
stride = options.maxx + 1 - options.minx
for i in range(len(cells), options.cells):
	x = options.minx + (i % stride)
	y = i // stride

	# create new Cell instance with random function
	cell = Cell("table_%04d" % i, x, options.miny + y // len(options.luts),
			options.luts[y % len(options.luts)])

	# set inputs (left, bottom, right, top)
	left = "gnd"
	below = "gnd"
	right = "gnd"
	above = "gnd"

	# find adjacent cell output names
	if x > options.minx:
		left = "table_%04d_out" % (i - 1)
	if x < options.maxx:
		right = "table_%04d_out" % (i + 1)
	if y > options.miny:
		below = "table_%04d_out" % (i - stride)
	if i < options.cells - stride:
		above = "table_%04d_out" % (i + stride)

	# connect inputs to adjacent cells
	cell.addInput(left)
	cell.addInput(below)
	cell.addInput(right)
	cell.addInput(above)

	# mark the nets as used
	used.add(left)
	used.add(below)
	used.add(right)
	used.add(above)

	cells.append(cell)

# connect the inputs randomly
for net in options.inputs:
	while True:
		cell = random.choice(cells)
		if cell.swapInput(net, "gnd") is not None:
			break
	used.add(net)

Cell.connectCells(cells)

# output cell specs to files
for cell in cells:
	print >>verilog, cell.getVerilog()
	if csv:   print >>csv, cell.getCSV()
	if place: print >>place, cell.getPlacement(options.prefix)

print >>verilog, ""

# make sure the input signals are assigned
for signal in options.inputs:
	if signal not in used:
		print "ERROR: input signal %s was not used!" % signal
		sys.exit(2)

# check for unused output signals that would otherwise get synthesized out
unused = set(outputs).difference(used)
if len(unused) > 0:
	if options.tieunused:
		print >>verilog, "assign tie_unused = %s;\n\n" % " & ".join(unused)
		print "INFO: %d unused signals tied to output: %s" % (len(unused), " ".join(unused))
	else:
		print "WARNING: %d unused signals may be removed: %s" % (len(unused), " ".join(unused))

elif options.tieunused:
	print >>verilog, "assign tie_unused = gnd;\n\n"

# end of module
print >>verilog, "endmodule\n"

# close files
verilog.close()
if csv:
	csv.close()
if place:
	place.close()

print "created module: %s" % options.module
print "saved to file: %s" % options.filename

