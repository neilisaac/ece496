#!/usr/bin/env python2.7

import sys

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
				sys.stderr.write("WARNING: ignoring placement block: {:s}\n".format(block))


	def generate(self):	
		for col in range(self.cols-1):
			for row in range(self.rows):
				self.gen_sb(self.sb[col][row], col, row)
				self.gen_cb(self.cbx[col+1][row], col+1, row, "x")
				if row < self.rows-1:
					self.gen_cb(self.cby[col][row+1], col, row+1, "y")
					self.gen_lb(self.lb[col+1][row+1], col+1, row+1)
	
		col = self.cols-1
		self.gen_sb(self.sb[col][0], col, 0)
		for row in range(1, self.rows):
			self.gen_cb(self.cby[col][row], col, row, "y")
			self.gen_sb(self.sb[col][row], col, row)
	

	def gen_cb(self, cb, x, y, orientation):
		print "# cb", x, y
		lb1 = [False for t in range(self.bitgen.lbpins)]
		lb2 = [False for t in range(self.bitgen.lbpins)]
		sb1 = [False for t in range(self.bitgen.tracks)]
		sb2 = [False for t in range(self.bitgen.tracks)]

		print "#", cb
		for dst, src in cb:
			num = None

			if dst.kind == "CHANX":
				if src.kind == "CHANX":
					num = 0
					if src.value != dst.value:
						raise Exception, "switching tracks isn't supported"
				elif src.kind == "CHANY":
					num = 0
					# TODO: check to make sure it's aligned correctly for the sb
				elif src.kind == "OPIN":
					if src.y > y:
						# bottom pins are 8-11, want value 1-4
						num = 1 + src.value - 2 * self.bitgen.lbpins
						if src.qualifier == "Pad":
							num = 1
					else:
						# top pins are 0-3, want value 5-8
						num = 1 + src.value + self.bitgen.lbpins
						if src.qualifier == "Pad":
							num = 1 + self.bitgen.lbpins
				else:
					raise Exception, "unknown src/dst kind combination"

				if dst.value % 2 == 0: # right
					sb2[dst.value / 2] = num
				else: # left
					sb1[dst.value / 2] = num

			elif dst.kind == "CHANY":
				if src.kind == "CHANY":
					num = 0
					if src.value != dst.value:
						raise Exception, "switching tracks isn't supported"
				elif src.kind == "CHANX":
					num = 0
					# TODO: check to make sure it's aligned correctly for the sb
				elif src.kind == "OPIN":
					if src.x > x:
						# left pins are 12-15, want value 5-8
						num = 1 + src.value - 2 * self.bitgen.lbpins
						if src.qualifier == "Pad":
							num = 1 + self.bitgen.lbpins
					else:
						# right pins are 4-7, want value 1-4
						num = 1 + src.value - self.bitgen.lbpins
						if src.qualifier == "Pad":
							num = 1
				else:
					raise Exception, "unknown src/dst kind combination"

				if dst.value % 2 == 0: # above
					sb1[dst.value / 2] = num
				else: # below
					sb2[dst.value / 2] = num

			elif dst.kind == "IPIN":
				if src.kind == "CHANX":
					if src.value % 2 == 0:
						num = 1 + src.value / 2
					else:
						num = 1 + src.value / 2 + self.bitgen.tracks

					if dst.y > y:
						if dst.qualifier == "Pad":
							lb1[0] = num
						else:
							lb1[dst.value - 2 * self.bitgen.lbpins] = num
					else:
						if dst.qualifier == "Pad":
							lb2[0] = num
						else:
							lb2[dst.value] = num

				elif src.kind == "CHANY":
					if src.value % 2 == 0:
						num = 1 + src.value / 2 + self.bitgen.tracks
					else:
						num = 1 + src.value / 2

					if dst.x > x:
						if dst.qualifier == "Pad":
							lb2[0] = num
						else:
							lb2[dst.value - self.bitgen.lbpins] = num
					else:
						if dst.qualifier == "Pad":
							lb1[0] = num
						else:
							lb1[dst.value - 3 * self.bitgen.lbpins] = num

				else:
					raise Exception, "unknown src kind for IPIN sink in gen_cb"

			else:
				raise Exception, "unknown dst kind from in gen_cb"

		self.bitgen.gen_cb(lb1, lb2, sb1, sb2)


	def gen_sb(self, sb, x, y):
		print "# sb", x, y
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

			# process subblocks, ordered by output pin number
			for subblock in sorted(lb[sub].clb.subblocks, key=lambda b: b[-2]):
				outpin = int(subblock[-2])
				index = outpin - 4 * self.bitgen.lbpins
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
				for pin in range(1, self.bitgen.lbpins + 1):
					selection = False
					try:
						selection = int(subblock[pin])
					except ValueError:
						if subblock[pin][:4] == "ble_":
							selection = 4 * self.bitgen.lbpins + int(subblock[pin][4:])
						elif subblock[pin] != "open":
							raise Exception, "unknown BLE pin assignment {:s}".format(subblock[pin]) 
					inputs[index * self.bitgen.inputs + pin - 1] = selection


		self.bitgen.gen_lb(inputs, functions, flops)



if __name__ == '__main__':
	import sys

	if len(sys.argv) != 5:
		sys.stderr.write("usage: {:s} <placement.out> <routing.out> <netlist.net> <logic.blif>\n".format(sys.argv[0]))
		sys.exit(1)
	
	placement = Placement(sys.argv[1])
	routing = Routing(sys.argv[2])
	netlist = NET(sys.argv[3])
	blif = BLIF(sys.argv[4])

	bitgen = Bitgen(cluster_size=4, ble_inputs=6, lb_inputs_per_side=4, tracks_per_direction=2, mux_size=5)

	fpga = FPGA(placement, routing, netlist, blif, bitgen)
	fpga.generate()

