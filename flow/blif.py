#!/usr/bin/env python2.7

import tokenizer

class Model:
	def __init__(self, name):
		self.name = name
		self.inputs = list()
		self.outputs = list() 
		self.latches = list()
		self.logic = list()

class Logic:
	def __init__(self):
		self.nets = None 
		self.table = list()

class BLIF:

	def __init__(self, filename):
		self.tokens = tokenizer.tokenize(filename)
		self.models = list()
		self.process()
	
	
	def process(self):
		context = None
		current = list()

		for line in self.tokens:
			if len(line) == 0:
				continue

			for tok in line:
				# new section
				if tok in ['.model', '.names', '.latch', '.inputs', '.outputs', '.end']:
					# action depending on current section
					if context == '.inputs':
						# inputs for model
						self.models[-1].inputs = current
						current = list()
					elif context == '.outputs':
						# outputs for model
						self.models[-1].outputs = current
						current = list()
					elif context == '.latch':
						# end of latch definition
						self.models[-1].latches.append(current)
						current = list()

					# action depending on current token
					if tok == '.names':
						# start of new logic table
						self.models[-1].logic.append(Logic())

					# move to new section
					if tok == '.end':
						context = None
					else:
						context = tok

				# can't handle subcircuits
				elif tok == '.subckt':
					raise Exception, "I don't know how to handle .subckt"

				# context is model, expecting a name
				elif context == '.model':
					self.models.append(Model(tok))

				# expecting a list of tokens until the next section
				elif context in ['.names', '.latch', '.inputs', '.outputs']:
					current.append(tok)

				# we should always be in a section
				elif context is None:
					raise Exception, "unexpected token " + tok

			# logic tables span multiple lines, but each line is significant
			if context == '.names':
				# find the logic table
				logic = self.models[-1].logic[-1]
				if logic.nets is None:
					# set the list of nets
					logic.nets = current
				else:
					# add a line to the table
					logic.table.append(current)

				# reset the current list
				current = list()
	
	
	def dump(self):
		for model in self.models:
			print "model:", model.name
			print "inputs:", model.inputs
			print "outputs:", model.outputs
			print "latches:"
			for latch in model.latches:
				print "\t", repr(latch)
			print "tables:"
			for table in model.logic:
				print "\tlogic", table.nets
				for line in table.table:
					print "\t\t", line
			print ""



if __name__ == "__main__":
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<blif file>"
		sys.exit(1)
	
	BLIF(sys.argv[1]).dump()

