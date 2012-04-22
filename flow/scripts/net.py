#!/usr/bin/env python2.7

import re
import tokenizer
from xml.etree import ElementTree

class Block:
	def __init__(self, xml):
		self.name = xml.attrib["name"]
		self.inst = xml.attrib["instance"]

		self.mode = None
		if "mode" in xml.attrib:
			self.mode = xml.attrib["mode"]

		self.inputs = dict()
		self.outputs = dict()
		self.globalnets = dict()
		self.blocks = list()
		self.pinlist = list()

		for subtag in xml:
			# build dictionaries of pins to net names
			if subtag.tag in ("inputs", "outputs", "globals"):
				for port in subtag:
					i = 0
					for net in port.text.split():
						net = re.sub("->.*", "", net)
						if subtag.tag == "inputs":
							if self.mode is not None:
								name = "{:s}.{:s}[{:d}]".format(self.mode, port.attrib["name"], i)
							else:
								name = "{:s}[{:d}]".format(port.attrib["name"], i)
							self.inputs[name] = net
						elif subtag.tag == "outputs":
							name = "{:s}.{:s}[{:d}]".format(self.inst, port.attrib["name"], i)
							self.outputs[name] = net
						else:
							self.globalnets[name] = net
						i += 1

			elif subtag.tag == "block":
				self.blocks.append(Block(subtag))

			else:
				raise Exception, "unknown tag: " + subtag.tag

		# find the real net for each output
		for output in self.outputs:
			src = self.outputs[output]
			for block in self.blocks:
				if src in block.outputs:
					self.outputs[output] = block.outputs[src]
					break

		# find the real net for each input to child blocks
		for block in self.blocks:
			for dst in block.inputs:
				src = block.inputs[dst]
				if src in self.inputs:
					block.inputs[dst] = self.inputs[src]
				else:
					for b in self.blocks:
						if src in b.outputs:
							block.inputs[dst] = b.outputs[src]
							break


class VPR6Net:

	def __init__(self, filename):
		# initialize data structures
		self.globalnets = list()
		self.inputs = list()
		self.outputs = list()
		self.clbs = dict()

		# open and read the xml file
		f = open(filename)
		text = f.read()
		f.close()

		# parse the xml
		xml = ElementTree.XML(text)
		for tag in xml:
			if tag.tag == "inputs":
				self.inputs.extend(tag.text.split())

			elif tag.tag == "outputs":
				self.outputs.extend(tag.text.split())

			elif tag.tag == "globals":
				self.globalnets.extend(tag.text.split())

			elif tag.tag == "block":
				if tag.attrib["mode"] == "clb":
					block = Block(tag)

					bles = dict()
					for ble in block.blocks:
						if len(ble.outputs) > 1:
							raise Exception, "BLE {:s} has {:d} outputs".format(ble.inst, len(ble.outputs))
						elif len(ble.outputs) == 1:
							bles[ble.outputs.values()[0]] = ble.inputs.values()

					self.clbs[block.name] = bles


			else:
				raise Exception, "unknown tag " + tag.tag




class CLB:
	def __init__(self, name):
		self.name = name
		self.pinlist = list()
		self.subblocks = list()


class VPR5Net:

	def __init__(self, filename):
		tokens = tokenizer.tokenize(filename)
		self.globalnets = list()
		self.inputs = list()
		self.outputs = list()
		self.clbs = dict()

		blocks = list()
		context = None
		subcontext = None

		for line in tokens:
			if len(line) == 0:
				continue

			for tok in line:
				# new section
				if tok in ['.global', '.clb', '.input', '.output']:
					context = tok
					subcontext = None

				# new subsection
				elif tok == 'pinlist:':
					subcontext = tok

				elif tok == 'subblock:':
					blocks[-1].subblocks.append(list())
					subcontext = tok

				# global net name (clock)
				elif context == '.global':
					self.globalnets.append(tok)

				# input pin
				elif context == '.input':
					if subcontext == 'pinlist:':
						self.inputs.append(tok)

				# ouput pin
				elif context == '.output':
					if subcontext == 'pinlist:':
						self.outputs.append(tok)

				# clb
				elif context == '.clb':
					if subcontext == 'pinlist:':
						blocks[-1].pinlist.append(tok)
					elif subcontext == 'subblock:':
						blocks[-1].subblocks[-1].append(tok)
					else:
						blocks.append(CLB(tok))

				# we should always be in a section
				elif context is None:
					raise Exception, "unexpected token " + tok

		for block in blocks:
			clb = dict()
			for ble in block.subblocks:
				clb[ble[0]] = list()
				for pin in ble[1:7]:
					try:
						name = block.pinlist[int(pin)]
					except ValueError:
						name = pin
					clb[ble[0]].append(name)
			self.clbs[block.name] = clb
	
	
# print out text version of interpreted data
def dump(self):
	print "globals:"
	for net in self.globalnets:
		print "\t", net

	print "inputs:"
	for net in self.inputs:
		print "\t", net

	print "outputs:"
	for net in self.outputs:
		print "\t", net

	for clb in self.clbs:
		print "clb:", clb
		for ble in self.clbs[clb]:
			print "\tble:", ble
			for pin in self.clbs[clb][ble]:
				print "\t\t" + pin


if __name__ == "__main__":
	import sys
	
	if len(sys.argv) != 3:
		print "usage:", sys.argv[0], " <5|6> <net file>"
		sys.exit(1)
	
	if sys.argv[1] == "5":
		dump(VPR5Net(sys.argv[2]))

	elif sys.argv[1] == "6":
		dump(VPR6Net(sys.argv[2]))

	else:
		print "usage:", sys.argv[0], " <5|6> <net file>"
		sys.exit(1)

