import math

class Bitgen:
	SB_NORTH = 0
	SB_EAST  = 1
	SB_SOUTH = 2
	SB_WEST  = 3

	def __init__(self, cluster_size, ble_inputs, lb_inputs_per_side, tracks_per_direction, mux_size):
		self.cluster = cluster_size
		self.inputs = ble_inputs
		self.lbpins = lb_inputs_per_side
		self.tracks = tracks_per_direction
		self.muxsize = mux_size

		if self.muxsize != 5:
			raise Exception, "I don't know about mux sizes other than 5"
	

	def gen_cb(self, lb1, lb2, sb1, sb2):
		for dest in [sb2, sb1]:
			for part in reversed([xbar_stream(pin, self.tracks) for pin in dest]):
				for pattern, length in part:
					print "{:d}:{:X}".format(length, pattern)

		for dest in [lb2, lb1]:
			for part in reversed([xbar_stream(pin, self.lbpins) for pin in dest]):
				for pattern, length in part:
					print "{:d}:{:X}".format(length, pattern)
	

	def gen_sb(self, north, east, south, west):
		# lowest-bit first ordering in params
		north = [(x - 1) % 4 for x in north]; north.reverse()
		east  = [(x - 2) % 4 for x in east];  east.reverse()
		south = [(x - 3) % 4 for x in south]; south.reverse()
		west  = [(x - 0) % 4 for x in west];  west.reverse()
		for pin in west + south + east + north:
			for pattern, length in xbar_stream(pin, 3):
				print "{:d}:{:X}".format(length, pattern)


	def gen_lb(self, inputs, functions, flops):
		for value in inputs:
			for pattern, length in xbar_stream(value, 4 * self.lbpins, self.muxsize):
				print "{:d}:{:X}".format(length, pattern)

		for function, flop in zip(functions, flops):
			print "1:{:X}".format(flop)
			print "{:d}:{:X}".format(2 ** self.inputs, function)



def xbar_stream(selected, signals, size=5):
	result = list()

	# next level
	muxes = math.ceil(float(signals) / size)
	if muxes > 1:
		if isinstance(selected, bool):
			result.extend(xbar_stream(selected, int(muxes), size))
		else:
			result.extend(xbar_stream(selected // size, int(muxes), size))
	
	if not isinstance(selected, bool):
		selected = selected % size

	# muxes at this level
	for i in range(int(muxes)):
		if isinstance(selected, bool) and selected is False:
			result.append((0x00000000, 32))
		elif isinstance(selected, bool) and selected is True:
			result.append((0xFFFFFFFF, 32))
		elif selected == 0:
			result.append((0xAAAAAAAA, 32))
		elif selected == 1:
			result.append((0xCCCCCCCC, 32))
		elif selected == 2:
			result.append((0xF0F0F0F0, 32))
		elif selected == 3:
			result.append((0xFF00FF00, 32))
		elif selected == 4:
			result.append((0xFFFF0000, 32))
		else:
			raise Exception, "unknown mux pattern"

	return result


