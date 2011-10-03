#!/usr/bin/env python2 

import sys
import time
import math
import serial
import optparse

parser = optparse.OptionParser()

parser.add_option("-d", "--device", dest="device", type="string",
		default="/dev/ttyUSB0", help="serial port device")
parser.add_option("-b", "--baud", dest="baud", type="int",
		default=115200, help="device baud rate")
parser.add_option("-t", "--timeout", dest="timeout", type="float",
		default=0.1, help="device write timeout")

options, args = parser.parse_args(sys.argv)

s = serial.Serial(options.device, baudrate=options.baud, timeout=options.timeout,
		bytesize=8, parity=serial.PARITY_EVEN)

def write(value):
	for i in range(5):
		s.write(chr(value))
		read = s.read()
		if len(read) > 0:
			break
	else:
		print "no response for {0:d} {:08:b}!".format(value)
		return False
	read = ord(read)
	if read != value:
		print "value read doesn't match value sent!"
		print "{:08b} -> {:08b}".format(value, read)
		return False
	return True

def serialize(values):
	bytelist = list()
	combined = "".join(["{0:0{1}b}".format(val, l) for val, l in values])
	if len(combined) % 8 != 0:
		combined = "{0:0{1}b}".format(0, 8 - len(combined) % 8) + combined
	for i in range(0, len(combined) - 1, 8):
		bytelist.append(int(combined[i:i+8], 2))
	return bytelist

def xbarstream(selected, signals, size):
	result = list()

	# next level
	muxes = math.ceil(float(signals) / size)
	if muxes > 1:
		if isinstance(selected, bool):
			result.extend(xbarstream(selected, int(muxes), size))
		else:
			result.extend(xbarstream(selected // size, int(muxes), size))
	
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

data = list()
for value in [ 2, 2, 2, 2, 0, 0, 0, 0, 0, 1, 0, 1]:
	data.extend(xbarstream(value, 3, 5))

for value in serialize(data):
	if not write(value):
		print "failed to write complete bitstream"
		sys.exit(1)

sys.exit(0)

