#!/usr/bin/env python2 

import sys
import time
import serial

s = serial.Serial("/dev/ttyUSB0", baudrate=115200, timeout=1,
		bytesize=8, parity=serial.PARITY_EVEN)

count = 0
for i in range(256):
	value = chr(i)
	for j in range(5):
		s.write(value)
		read = s.read()
		if len(read) > 0:
			value = ord(read)
			break
	else:
		print "no responce for {0:d} {0:08b}".format(i)

	if value == i:
		count += 1
	else:
		print "error {:08b} -> {:08b}".format(i, value)

print count

