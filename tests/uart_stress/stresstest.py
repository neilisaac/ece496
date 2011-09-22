#!/usr/bin/env python2 

import sys
import time
import serial

s = serial.Serial("/dev/ttyUSB0", baudrate=9600, timeout=1,
		bytesize=8, parity=serial.PARITY_NONE)

count = 0
offset = 0
for i in range(256):
	s.write(chr(i))
	time.sleep(0.01)
	v = s.read()
	if len(v) == 0:
		print "failed to read"
		break
	if ord(v) == i + offset:
		count += 1
	else:
		print "{:08b} -> {:08b}".format(i, ord(v))
		#print "off by", ord(v) - i
		#offset = ord(v) - i

print count

