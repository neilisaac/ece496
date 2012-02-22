#!/usr/bin/env python2.7

import tokenizer

class CLB:
	def __init__(self, name):
		self.name = name
		self.pinlist = list()
		self.subblocks = list()

class NET:

	def __init__(self, filename):
		tokens = tokenizer.tokenize(filename)
		self.globalnets = list()
		self.inputs = list()
		self.outputs = list()
		self.clbs = list()
		self.process(tokens)
	
	
	def process(self, tokens):
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
					self.clbs[-1].subblocks.append(list())
					subcontext = tok

				# global net name (clock)
				elif context == '.global':
					self.globalnets.append(tok)

				# input pin
				elif context == '.input':
					if subcontext == 'pinlist:':
						self.inputs[-1].append(tok)
					else:
						self.inputs.append(list())
						self.inputs[-1].append(tok)

				# ouput pin
				elif context == '.output':
					if subcontext == 'pinlist:':
						self.outputs[-1].append(tok)
					else:
						self.outputs.append(list())
						self.outputs[-1].append(tok)

				# clb
				elif context == '.clb':
					if subcontext == 'pinlist:':
						self.clbs[-1].pinlist.append(tok)
					elif subcontext == 'subblock:':
						self.clbs[-1].subblocks[-1].append(tok)
					else:
						self.clbs.append(CLB(tok))

				# we should always be in a section
				elif context is None:
					raise Exception, "unexpected token " + tok
	
	
	def dump(self):
		print "globals:"
		for net in self.globalnets:
			print "\t", net

		print "inputs:"
		for nets in self.inputs:
			print "\t", nets[0], nets[1]

		print "outputs:"
		for nets in self.outputs:
			print "\t", nets[0], nets[1]

		for clb in self.clbs:
			print "clb:", clb.name
			i = 0
			print "\tpinlist:"
			for pin in clb.pinlist:
				print "\t\t", str(i) + ":", pin
				i += 1
			for subblock in clb.subblocks:
				print "\tsubblock:"
				for pin in subblock:
					try:
						name = clb.pinlist[int(pin)]
						print "\t\t", pin, "(" + name + ")"
					except ValueError:
						print "\t\t", pin



if __name__ == "__main__":
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<net file>"
		sys.exit(1)
	
	NET(sys.argv[1]).dump()

