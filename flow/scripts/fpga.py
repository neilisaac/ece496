#!/usr/bin/env python2.7

import sys
from collections import deque

from placement import Placement, Block
from routing import Routing
from net import VPR5Net, VPR6Net
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
				if block.name in self.netlist.clbs:
					block.clb = self.netlist.clbs[block.name]
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

		if len(lb) == 0:
			return
		elif len(lb) > 1:
			raise Exception, "Expecting exactly 1 logic block at ({:d},{:d}) with subblock #0".format(x, y)

		lb = lb[0]

		# map pin indices in netlist to routed pin numbers
		assignments = dict()
		unassigned = list()
		net_to_physical_pin = dict()

		# find the real BLE pin number that each output net is routed to
		for ble in lb.clb:
			print "#", ble, lb.clb[ble]
			if ble in self.nets:
				node = self.nets[ble][1]
				if node.kind != "OPIN" or node.qualifier != "Pin":
					raise Exception, "expecting CLB pin to drive net " + ble
				net_to_physical_pin[ble] = node.value - 4 * self.bitgen.lbpins
				assignments[net_to_physical_pin[ble]] = ble
			else:
				unassigned.append(ble)

		# assign the remaining BLEs
		for ble in unassigned:
			for index in range(self.bitgen.cluster):
				if index not in assignments:
					assignments[index] = ble
					net_to_physical_pin[ble] = index
					break

		print "# assignments", assignments

		for index in assignments:
			ble = assignments[index]
			key = ble

			# is the sink latched?
			# if so, set key to the intermediate net name
			if ble in self.flops:
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
			for pin in range(self.bitgen.inputs):
				selection = False
				net = lb.clb[ble][pin]
				if net == "open":
					pass
				elif net in net_to_physical_pin:
					selection = net_to_physical_pin[net]
				elif net in self.nets:
					for node in self.nets[net]:
						if node.kind == "IPIN" and node.qualifier == "Pin":
							if node.x == x and node.y == y:
								selection = node.value + self.bitgen.cluster
								break
				else:
					raise Exception, "unknown BLE pin assignment for {:s}".format(net) 

				inputs[index * self.bitgen.inputs + pin] = selection
				print "# ble", index, "pin", pin, ":", selection, "(", net, ")"

		self.bitgen.gen_lb(inputs, functions, flops)



if __name__ == '__main__':
	import sys

	if len(sys.argv) != 6:
		sys.stderr.write("usage: {:s} <placement.out> <routing.out> <netlist.net> <logic.blif>\n".format(sys.argv[0]))
		sys.exit(1)
	
	placement = Placement(sys.argv[1])
	routing = Routing(sys.argv[2])
	netlist = VPR6Net(sys.argv[3])
	blif = BLIF(sys.argv[4])
	tracks = int(sys.argv[5]) / 2

	bitgen = Bitgen(cluster_size=4, ble_inputs=6, lb_inputs_per_side=4, tracks_per_direction=tracks, mux_size=5)

	fpga = FPGA(placement, routing, netlist, blif, bitgen)
	fpga.generate()

