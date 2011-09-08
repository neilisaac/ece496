#!/usr/bin/env python2 

import sys
import time
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
		bytesize=8, parity=serial.PARITY_NONE)

def serialize(values):
	bytelist = list()
	combined = "".join(["{0:0{1}b}".format(val, l) for val, l in values])
	if len(combined) % 8 != 0:
		combined = "{0:0{1}b}".format(0, 8 - len(combined) % 8) + combined
	for i in range(0, len(combined) - 1, 8):
		bytelist.append(int(combined[i:i+8], 2))
	return bytelist

data = (
		# connect inputs of all LUTs to DIP[5:0]
		(9, 4), (8, 4), (7, 4), (6, 4), (5, 4), (4, 4),
		(9, 4), (8, 4), (7, 4), (6, 4), (5, 4), (4, 4),
		(9, 4), (8, 4), (7, 4), (6, 4), (5, 4), (4, 4),
		(9, 4), (8, 4), (7, 4), (6, 4), (5, 4), (4, 4),
		(0x0FFFFFFFFFFFFFFFF, 65), # always 1
		(0x08000000000000000, 65), # AND gate
		(0x0FFFFFFFFFFFFFFFE, 65), # OR gate
		(0x0AAAAAAAAAAAAAAAA, 65), # odd numbers
	)

for value in serialize(data):
	s.write(chr(value))

	time.sleep(0.001)

	read = s.read()
	if len(read) == 0:
		print "failed to read result!"
		break

	read = ord(read)

	if read != value:
		print "value read doesn't match value sent!"
		print "{:08b} -> {:08b}".format(value, read)

