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

	def __repr__(self):
		return "{:s} {:d} {:d} {:s} {:d}".format(self.kind, self.x, self.y, self.qualifier, self.value)

	def dump(self):
		print repr(self)


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
				self.width = int(tokens[0][2])
				self.height = int(tokens[0][4])

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
	
	def infer(self):
		cby = [[list() for row in range(self.height + 1)] for col in range(self.width + 1)]
		cbx = [[list() for row in range(self.height + 1)] for col in range(self.width + 1)]
		sb = [[list() for row in range(self.height + 1)] for col in range(self.width + 1)]

		for net in self.nets:
			prev = None
			for node in net.nodes:
				if prev is None:
					prev = node
					continue

				# connection block interconnect drivers
				if node.kind == "CHANX":
					cbx[node.x][node.y].append((node, prev))
				elif node.kind == "CHANY":
					cby[node.x][node.y].append((node, prev))

				# connection block driving logic block or pad input
				if node.kind == "IPIN":
					if prev.kind == "CHANX":
						cbx[prev.x][prev.y].append((node, prev))
					elif prev.kind == "CHANY":
						cby[prev.x][prev.y].append((node, prev))
					else:
						raise Exception, "unknown routing connection"

				# switch block drives cb-cb routes
				if prev.kind in ["CHANX", "CHANY"] and node.kind in ["CHANX", "CHANY"]:
					x = min(prev.x, node.x)
					y = min(prev.y, node.y)
					sb[x][y].append((node, prev))

				prev = node

		return cby, cbx, sb
	
	def dump(self):
		for net in self.nets:
			print "net", net.num, net.name
			for node in net.nodes:
				print "\t", 
				node.dump()

		cby, cbx, sb = self.infer()

		print "vertical connection blocks:"
		x = 0
		for col in cby:
			y = 0
			for row in col:
				print "\tconnection block", x, y
				for dst, src in row:
					print "\t\t", src, "->", dst
				y += 1
			x += 1

		print "horizontal connection blocks:"
		x = 0
		for col in cbx:
			y = 0
			for row in col:
				print "\tconnection block", x, y
				for dst, src in row:
					print "\t\t", src, "->", dst
				y += 1
			x += 1

		print "switch blocks:"
		x = 0
		for col in sb:
			y = 0
			for row in col:
				print "\tswitch block", x, y
				for dst, src in row:
					print "\t\t", src, "->", dst
				y += 1
			x += 1


if __name__ == '__main__':
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<routing file>"
		sys.exit(1)
	
	Routing(sys.argv[1]).dump()


