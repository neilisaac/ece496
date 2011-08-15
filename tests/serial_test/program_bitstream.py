#!/usr/bin/env python2 

import sys
import time
import serial
import optparse

parser = optparse.OptionParser()

parser.add_option("-d", "--device", dest="device", type="string",
		default="/dev/ttyS0", help="serial port device")
parser.add_option("-b", "--baud", dest="baud", type="int",
		default=115200, help="device baud rate")
parser.add_option("-t", "--timeout", dest="timeout", type="float",
		default=0.1, help="device write timeout")

options, args = parser.parse_args(sys.argv)

s = serial.Serial(options.device, baudrate=options.baud, timeout=options.timeout,
		bytesize=8, parity=serial.PARITY_NONE)

data = (
		# enable flop
		0x01,

		# 64-bit function
		0x7F,
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFF,
		0xFE,
	)

for value in data:
	s.write(chr(value))

	time.sleep(0.001)

	read = s.read()
	if len(read) == 0:
		break

	read = ord(read)
	print "{:08b}".format(read)

	if read != value:
		print "value read doesn't match value sent!"

