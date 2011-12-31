#!/usr/bin/env python2.7

import tokenizer

class Block:
	def __init__(self, name, x, y, subblock, number):
		self.name = name
		self.x = x
		self.y = y
		self.subblock = subblock
		self.number = number
	
	def dump(self):
		print "block #{:d} {:s} ({:d}, {:d}) subblock {:d}".format(self.number, self.name, self.x, self.y, self.subblock)


class Placement:
	def __init__(self, filename):
		tokens = tokenizer.tokenize(filename)
		self.blocks = dict()
		self.width = 0
		self.height = 0

		if tokens[1][0] != "Array":
			raise Exception, "placement file format doesn't match my expectations"
		
		self.width = int(tokens[1][2])
		self.height = int(tokens[1][4])

		num = 0
		for line in tokens:
			if len(line) != 4:
				continue

			if line[0] in self.blocks:
				raise Exception, "block with same name appears twice in placement file"

			# columns: name, x, y, subblk, block number in a comment
			self.blocks[line[0]] = Block(line[0], int(line[1]), int(line[2]), int(line[3]), num)
			num += 1
	

	def dump(self):
		for block in sorted(self.blocks.values(), key=lambda b: b.number):
			block.dump()


if __name__ == '__main__':
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<placement file>"
		sys.exit(1)
	
	Placement(sys.argv[1]).dump()


