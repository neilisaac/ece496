#!/usr/bin/env python2

import sys
import optparse
import random

parser = optparse.OptionParser()

parser.add_option("-f", "--file", action="store", type="string",
		dest="filename", default="output.v", help="output file name")
parser.add_option("-m", "--module", action="store", type="string",
		dest="module", default="mutated_individual", help="verilog module name")
parser.add_option("-i", "--input", action="store", type="string",
		dest="input", default="in", help="input signal")
parser.add_option("-o", "--output", action="store", type="string",
		dest="output", default="out", help="input signal")
parser.add_option("-c", "--cells", action="store", type="int",
		dest="cells", default=10, help="number of LEs")
parser.add_option("-s", "--seed", action="store", type="string",
		dest="seed", default=None, help="seed vqm file")
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

out = open(options.filename, "w")

# create module
print >>out, "module %s (" % options.module
print >>out, "\t%s," % options.input
print >>out, "\t%s\n);\n" % options.output

print >>out, "input %s;" % options.input
print >>out, "output %s;\n" % options.output

# define names for all wires that can drive a value
outputs = ["vdd", "gnd"] + ["output%d" % i for i in range(options.cells)]
for wire in outputs:
	print >>out, "(* keep *) wire %s;" % wire

# the module's input can also drive cell inputs
outputs.append(options.input)

# set values for vdd and gnd
print >>out, "\nassign vdd = 1'b1;"
print >>out, "assign gnd = 1'b0;\n"

# connect the output of cell 0 to the module's output
print >>out, "assign %s = output0;\n" % options.output

# keep set of used outputs
used = set()

# create the lookup tables
for i in range(options.cells):
	# instantiate module
	name = "table%d" % i
	print >>out, "\ncycloneii_lcell_comb %s (" % name

	# create input wires with randomly assigned drivers
	for letter in ["a", "b", "c", "d"]:
		wire = random.choice(outputs)
		print >>out, "\t.data%s(%s)," % (letter, wire)
		used.add(wire)

	# assign module output
	print >>out, "\t.combout(output%d) );\n" % i;

	# set the module's function
	mask = random.randint(0x0000, 0xFFFF)
	print >>out, "defparam %s .lut_mask = \"%04X\";\n" % (name, mask)

	# not sure what assigning .sum_lutc_input gives
	#print >>out, "defparam %s .sum_lutc_input = \"cin\";" % name

# end of module
print >>out, "endmodule"

out.close()

if options.input not in used:
	print "ERROR: input signal %s was not used!" % options.input
	sys.exit(2)
else:
	used.remove(options.input)

if "vdd" in used:
	used.remove("vdd")
if "gnd" in used:
	used.remove("gnd")

print "created module: %s" % options.module
print "used %d of %d output signals" % (len(used), len(outputs) - 3)
print "saved to file: %s" % options.filename

