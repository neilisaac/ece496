import random

class Cell:

	master = "cycloneii_lcell_comb"
	terminals = ["dataa", "datab", "datac", "datad"]



	def __init__(self, name, x, y, n, inputs=None, function=None):
		self.name = name
		self.output = name + "_out"
		self.function = function
		self.inputs = inputs
		self.location = (x, y, n)
		self.sources = list()
		self.sinks = list()

		if self.function is None:
			self.setFunction()

		if self.inputs is None:
			self.inputs = list()
	


	def __str__(self):
		return self.name



	def swapInput(self, new, old=None):
		if old is None:
			old = random.choice(self.inputs)
		elif old not in self.inputs:
			raise Exception, "%s doesn't have input net %s" % (self.name, old)
		
		index = self.inputs.index(old)
		self.inputs[index] = new
		return old



	def mutateFunction(self, bits=1):
		mask = 0
		for i in range(bits):
			while True:
				bit = 1 << random.randint(0, 15)
				if (mask & bit) == 0:
					mask |= bit
					break

		self.function ^= mask

	

	def setFunction(self, function=None):
		if function is None:
			self.function = random.randint(0x0000, 0xFFFF)
		else:
			self.function = function
	


	def setInputs(self, nets):
		self.inputs = nets
	


	def addInput(self, net):
		if net == self.output:
			return False
		
		self.inputs.append(net)
		return True



	def addSource(self, source):
		self.sources.append(source)
	


	def addSink(self, sink):
		self.sinks.append(sink)



	def getFunctionHex(self):
		return "%04X" % self.function



	def getCSV(self):
		if len(self.inputs) != 4:
			raise Exception, "%s doesn't have 4 inputs: %s" % (self.name, ", ".join(self.inputs))

		x, y, n = self.location
		return "%s,%s,%s,%s,%s,%s,%04X,%d,%d,%d" % (self.name,
				self.inputs[0], self.inputs[1], self.inputs[2], self.inputs[3],
				self.output, self.function, x, y, n)
	


	def getPlacement(self, prefix=""):
		return "set_location_assignment LCCOMB_X%d_Y%d_N%d -to %s%s" % \
				(self.location + (prefix, self.output))
	


	def getVerilog(self):
		verilog = "%s %s (\n" % (Cell.master, self.name)

		for term, net in zip(Cell.terminals, self.inputs):
			verilog += "\t.%s(%s),\n" % (term, net)

		verilog += "\t.combout(%s) );\n" % self.output
		verilog += "defparam %s .lut_mask = \"%04X\";\n" % (self.name, self.function)
		verilog += "/* %s */\n" % self.getPlacement()
		return verilog



	@staticmethod
	def connectCells(cells):
		for source in cells:
			for sink in cells:
				if source.output in sink.inputs:
					sink.addSource(source)
					source.addSink(sink)



	@staticmethod
	def readCSV(line):
		parts = line.split(",")
		name = parts[0]
		inputs = parts[1:5]
		output = parts[5]
		function = int(parts[6], 16)
		x = int(parts[7])
		y = int(parts[8])
		n = int(parts[9])
		return Cell(name, x, y, n, inputs, function)


