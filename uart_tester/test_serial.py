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

s = serial.Serial(options.device,baudrate=options.baud, timeout=options.timeout,
		bytesize=8, parity=serial.PARITY_NONE)

s.write(chr(0xAA))

while True:
	data = s.read()
	if len(data) == 0:
		break

	num = ord(data)
	bits = list()
	for i in range(8):
		value = (num >> (7 - i)) & 1
		bits.append(str(value))

	print "".join(bits)

