#!/usr/bin/env python2 

import sys
import time
import serial

device = "/dev/ttyUSB0"
timeout = 5

if len(sys.argv) > 1:
	device = sys.argv[1]

s = serial.Serial(device, baudrate=9600, bytesize=8,
		parity=serial.PARITY_NONE, timeout=timeout)

time.sleep(0.001)
s.write("S")

time.sleep(0.001)
data = s.read()

if len(data) != 1:
	print "ERROR: test board didn't respond at all"
	sys.exit(1)

if data != "R":
	print "ERROR: test board didn't respond properly"
	sys.exit(1)

else:
	score = 0

	data = s.read(4)
	if len(data) != 4:
		print "ERROR: test board didn't sent valid score bytes"
		sys.exit(1)

	for value, i in zip(data, [0, 8, 16, 24]):
		score += ord(value) << i

	print "score is: %8d (0x%08X)" % (score, score)

