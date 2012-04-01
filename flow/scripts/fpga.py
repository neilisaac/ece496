#!/usr/bin/env python2.7

import sys
from collections import deque

from placement import Placement, Block
from routing import Routing
from net import NET
from blif import BLIF
from bitgen import Bitgen

class FPGA:

	def __init__(self, placement, routing, netlist, blif, bitgen):
		self.placement = placement
		self.routing = routing
		self.netlist = netlist
		self.blif = blif
		self.bitgen = bitgen

		self.rows = placement.height + 1
		self.cols = placement.width + 1

		self.cby, self.cbx, self.sb = routing.infer()

		# make a dictionary of CLBs, hashed by name
		clbs = dict()
		for clb in netlist.clbs:
			clbs[clb.name] = clb

		# make a dictionary of routing nets, hashed by net name
		self.nets = dict()
		for net in routing.nets:
			self.nets[net.name] = net.nodes

		# make a dictionary of logic functions and flops, by output net name
		self.functions = dict()
		self.flops = dict()
		for model in blif.models:
			for logic in model.logic:
				if logic.nets[-1] in self.functions:
					raise Exception, "sink node {:s} appears more than once in blif".format(logic.nets[-1])
				self.functions[logic.nets[-1]] = logic

			for latch in model.latches:
				if latch[1] in self.flops:
					raise Exception, "latched sink node {:s} appears more than once in blif".format(latch[1])
				self.flops[latch[1]] = latch

		self.lb = [[dict() for row in range(self.rows)] for col in range(self.cols)]
		for block in placement.blocks.values():
			if 0 < block.x < self.cols and 0 < block.y < self.rows:
				self.lb[block.x][block.y][block.subblock] = block
				if block.name in clbs:
					block.clb = clbs[block.name]
				else:
					raise Exception, "couldn't find CLB for " + block.name + " in the netlist"
			else:
				#sys.stderr.write("WARNING: ignoring placement block: {:s}\n".format(block))
				pass


	def generate(self):	
		col = self.cols-1
		for row in range(self.rows-1, 0, -1):
			self.gen_sb(self.sb[col][row], col, row)
			self.gen_cb(self.cby[col][row], col, row, "y")
		self.gen_sb(self.sb[col][0], col, 0)

		for col in range(self.cols-2, -1, -1):
			for row in range(self.rows-1, -1, -1):
				if row < self.rows-1:
					self.gen_lb(self.lb[col+1][row+1], col+1, row+1)
					self.gen_cb(self.cby[col][row+1], col, row+1, "y")
				self.gen_cb(self.cbx[col+1][row], col+1, row, "x")
				self.gen_sb(self.sb[col][row], col, row)
	

	def gen_cb(self, cb, x, y, orientation):
		print "# cb", orientation, x, y
		lb1 = [False for t in range(self.bitgen.lbpins)]
		lb2 = [False for t in range(self.bitgen.lbpins)]
		sb1 = [False for t in range(self.bitgen.tracks)]
		sb2 = [False for t in range(self.bitgen.tracks)]

		print "#", cb
		for dst, src in cb:
			# ignore sinks in list
			# sinks are there when there's a fanout net
			if src.kind == "SINK":
				continue

			num = None

			# find the real source
			for dst1, src1 in cb:
				if dst1 == src:
					print "# swapped direct source:", src, "<-", src1
					src = src1

			print "# connect:", dst, "<-", src

			# driving switch block pin
			if dst.kind in ("CHANX", "CHANY"):
				# connection block to connection block is always straight-through
				if src.kind in ("CHANX", "CHANY"):
					# TODO: check for valid track
					num = 0

				# BLE output driving connection block bus to switch block
				elif src.kind == "OPIN":
					num = self.bitgen.cluster / 4
					if src.qualifier != "Pad":
						num += (src.value - 4 * self.bitgen.lbpins) % (self.bitgen.cluster / 4)

					if (orientation == "y" and src.x > x) or (orientation == "x" and src.y == y):
						num += self.bitgen.cluster / 4

				# catch invalid connections as a sanity check
				else:
					raise Exception, "unknown src/dst kind combination: " + str(dst) + " <- " + str(src)

				# save connection
				if orientation == "y":     # switch block above/below
					if dst.value % 2 == 0: # above
						sb1[dst.value / 2] = num
					else:                  # below
						sb2[dst.value / 2] = num
				else:                      # switch block left/right
					if dst.value % 2 == 0: # right
						sb2[dst.value / 2] = num
					else:                  # left
						sb1[dst.value / 2] = num

			# driving logic block pin 
			elif dst.kind == "IPIN":
				if src.kind in ("CHANX", "CHANY"):
					num = (self.bitgen.cluster / 4) + (src.value / 2)
					if orientation == "y" and src.y < y:
						num += self.bitgen.tracks
					elif orientation == "x" and src.x >= x:
						num += self.bitgen.tracks

				elif src.kind == "OPIN":
					# connection is stright through
					num = 0
					if src.kind != "Pad":
						num = (src.value - 4 * self.bitgen.lbpins) % (self.bitgen.cluster / 4)

				else:
					raise Exception, "unknown src kind for IPIN sink in gen_cb: " + src

				# get destination pin index
				index = 0
				if dst.qualifier != "Pad":
					index = dst.value % self.bitgen.lbpins

				# save connection
				if (orientation == "y" and dst.x == x) or (orientation == "x" and dst.y > y):
					lb1[index] = num
				else:
					lb2[index] = num

		self.bitgen.gen_cb(lb1, lb2, sb1, sb2)


	def gen_sb(self, sb, x, y):
		print "# sb", x, y
		print "#", sb
		north = [Bitgen.SB_SOUTH for t in range(self.bitgen.tracks)]
		east  = [Bitgen.SB_WEST  for t in range(self.bitgen.tracks)]
		south = [Bitgen.SB_NORTH for t in range(self.bitgen.tracks)]
		west  = [Bitgen.SB_EAST  for t in range(self.bitgen.tracks)]

		for dst, src in sb:
			direction = None
			if src.kind == "CHANX":
				if src.x > x:
					direction = Bitgen.SB_EAST
				else:
					direction = Bitgen.SB_WEST
			elif src.kind == "CHANY":
				if src.y > y:
					direction = Bitgen.SB_NORTH
				else:
					direction = Bitgen.SB_SOUTH
			else:
				raise Exception, "unknown dst node kind in gen_sb"

			if dst.kind == "CHANX":
				if dst.x > x:
					east[dst.value / 2] = direction
				else:
					west[dst.value / 2] = direction
			elif dst.kind == "CHANY":
				if dst.y > y:
					north[dst.value / 2] = direction
				else:
					south[dst.value / 2] = direction
			else:
				raise Exception, "unknown dst node kind in gen_sb"

		self.bitgen.gen_sb(north, east, south, west)


	def gen_lb(self, lb, x, y):
		print "# lb", x, y

		inputs    = [False for f in range(self.bitgen.cluster * self.bitgen.inputs)]
		functions = [False for f in range(self.bitgen.cluster)]
		flops     = [False for f in range(self.bitgen.cluster)]

		for sub in lb:
			if sub != 0:
				raise Exception, "I'm not sure what a non-zero subblock for a CLB means"

			# map pin indices in netlist to routed pin numbers
			pins = dict()
			for i, pin in zip(range(len(lb[sub].clb.pinlist)), lb[sub].clb.pinlist):
				if pin == "open": pass

				# find input pin
				elif i < 4 * self.bitgen.lbpins:
					if pin not in self.nets:
						raise Exception, "couldn't find output net " + pin
					pins[i] = dict()
					for node in self.nets[pin]:
						if node.kind == "IPIN" and node.qualifier == "Pin":
							pins[i][(node.x, node.y)] = node.value + self.bitgen.cluster

				# find output pin
				elif i < 4 * self.bitgen.lbpins + self.bitgen.cluster:
					if pin not in self.nets:
						raise Exception, "couldn't find input net " + pin
					node = self.nets[pin][1]
					if node.kind != "OPIN" or node.qualifier != "Pin":
						raise Exception, "expecting CLB pin to drive net " + pin
					pins[i] = node.value - 4 * self.bitgen.lbpins

				# ignore clk pin

			print "# pins", pins

			# make a list of subblocks where subblocks which have
			# a specific output pin are at the start of the list
			subblocks = deque()
			n = 0
			for subblock in lb[sub].clb.subblocks:
				if int(subblock[-2]) in pins:
					subblocks.appendleft((n, subblock))
				else:
					subblocks.append((n, subblock))
				n += 1

			# assign the subblocks
			assignments = dict()
			net_to_physical_order = dict()
			for n, subblock in subblocks:
				pin = int(subblock[-2])
				if pin in pins:
					assignments[pins[pin]] = subblock
					net_to_physical_order[n] = pins[pin]
				else:
					for i in range(self.bitgen.cluster):
						if i not in assignments.keys():
							assignments[i] = subblock
							net_to_physical_order[n] = i
							break

			print "# net to physical", net_to_physical_order
			print "# assignments", assignments

			for index in sorted(assignments.keys()):
				subblock = assignments[index]
				key = subblock[0]

				# is the sink latched?
				if key in self.flops:
					flops[index] = True
					key = self.flops[key][0]

				# get the logic function
				try:
					func = self.functions[key].func
					if func is None:
						sys.stderr.write("WARNING: no logic function computed for sink node {:s}\n".format(key))
						func = 0
					functions[index] = func
				except KeyError:
					raise Exception, "can't find logic function for sink node {:s} in blif".format(key)

				# determine the input routing for each BLE pin
				for pin in range(1, self.bitgen.inputs + 1):
					selection = False
					try:
						selection = pins[int(subblock[pin])][(x ,y)]
					except ValueError:
						if subblock[pin][:4] == "ble_":
							selection = net_to_physical_order[int(subblock[pin][4:])]
						elif subblock[pin] != "open":
							raise Exception, "unknown BLE pin assignment {:s}".format(subblock[pin]) 
					print "# ble", index, "pin", pin, ":", selection, "(", subblock[pin], ")"
					inputs[index * self.bitgen.inputs + pin - 1] = selection


		self.bitgen.gen_lb(inputs, functions, flops)



if __name__ == '__main__':
	import sys

	if len(sys.argv) != 6:
		sys.stderr.write("usage: {:s} <placement.out> <routing.out> <netlist.net> <logic.blif>\n".format(sys.argv[0]))
		sys.exit(1)
	
	placement = Placement(sys.argv[1])
	routing = Routing(sys.argv[2])
	netlist = NET(sys.argv[3])
	blif = BLIF(sys.argv[4])
	tracks = int(sys.argv[5]) / 2

	bitgen = Bitgen(cluster_size=4, ble_inputs=6, lb_inputs_per_side=4, tracks_per_direction=tracks, mux_size=5)

	fpga = FPGA(placement, routing, netlist, blif, bitgen)
	fpga.generate()

