#!/usr/bin/env python2 

import sys
import time
import serial
import stats
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

time.sleep(0.001)

value = 0xFFFE # function: z = x3 & x2 & x1 & ~x0

s.write(chr(0x00))					# disable flop
s.write(chr((value >> 8) & 0xFF))	# upper 8 bytes
s.write(chr(value & 0xFF))			# lower 8 bytes

