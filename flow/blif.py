#!/usr/bin/env python2.7

from collections import deque

class blif:

	def __init__(self, filename):
		self.input = None
		
		self.read(filename)
		self.process()
	
	
	def process(self):
		context = None
		for line in self.input:
			for tok in line:
				if tok in ['.model', '.names', '.latch', '.inputs', '.outputs', '.subckt', '.end']:
					context = tok
	
	
	def read(self, filename):
		self.input = list()
		stream = open(filename)
		data = stream.readlines()
		
		concat = False
		for line in data:
			concatnext = False
			tokens = line.split()
			if len(tokens) > 0 and tokens[-1] == "\\":
				concatnext = True
				tokens = tokens[:-1]
			if concat:
				self.input[-1].extend(tokens)
			else:
				self.input.append(tokens)
			concat = concatnext
	
	
	def dump_input(self):
		for line in self.input:
			for tok in line:
				print tok,
				if tok == '.names':
					context = tok
			print ""
	
	
	def dump_output(self):
		pass



if __name__ == "__main__":
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<blif file>"
		sys.exit(1)
	
	data = blif(sys.argv[1])
	data.dump_input()
	print "----------"
	data.dump_output()

