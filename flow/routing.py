#!/usr/bin/env python2.7

import re
import tokenizer

class Node:
	def __init__(self, kind, x, y, qualifier, value):
		self.kind = kind
		self.x = x
		self.y = y
		self.qualifier = qualifier
		self.value = value

	def dump(self):
		print "node:", self.kind, self.x, self.y, self.qualifier, self.value


class Net:
	def __init__(self, num, name):
		self.num = num
		self.name = name
		self.nodes = list()


class Routing:
	def __init__(self, filename):
		tokens = tokenizer.tokenize(filename, midcomments=False)
		self.width = 0
		self.height = 0
		self.nets = list()
		self.process(tokens)
		
	def process(self, tokens):
		if tokens[0][0] != "Array":
			raise Exception, "placement file format doesn't match my expectations"

		for line in tokens:
			if len(line) == 0 or line[0] == "Routing:":
				continue

			if line[0] == "Array":
				self.width = tokens[0][2]
				self.height = tokens[0][4]

			elif line[0] == "Net":
				num = int(line[1])
				name = re.sub("\).*$", "", re.sub("^\(", "", line[2]))
				self.nets.append(Net(num, name))

			elif line[0] == "Block":
				print "ignoring:", " ".join(line)

			else:
				if len(self.nets) == 0:
					raise Exception, "routing file doesn't match expected format"
				
				coord = re.sub("\).*$", "", re.sub("^\(", "", line[1]))
				coord = coord.split(",")
				x = int(coord[0])
				y = int(coord[1])
				qualifier = re.sub(":.*", "", line[2])
				self.nets[-1].nodes.append(Node(line[0], x, y, qualifier, int(line[3])))
	
	def dump(self):
		for net in self.nets:
			print "net", net.num, net.name
			for node in net.nodes:
				print "\t", 
				node.dump()


if __name__ == '__main__':
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<routing file>"
		sys.exit(1)
	
	Routing(sys.argv[1]).dump()


