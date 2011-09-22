#!/usr/bin/env python2 

import sys
import time
import serial
import random

s = serial.Serial("/dev/ttyUSB0", baudrate=9600, timeout=0.1,
		bytesize=8, parity=serial.PARITY_NONE)

while True:
	break
	s.write(chr(12))
	time.sleep(0.001)
	if ord(s.read()) != 12:
		break

count = 0
while True:
	value = random.randint(0, 255)

	for i in range(5):
		s.write(chr(value))
		read = s.read()
		if len(read) > 0:
			break
	else:
		print "failed to read result!"
		break

	read = ord(read)
	if read != value:
		print "value corrupted!"
		print "{0:3d} {0:08b} -> {1:3d} {1:08b}".format(value, read)
		break

	count += 1

print "failed after", count, "good bytes"

