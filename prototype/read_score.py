#!/usr/bin/env python2 

import sys
import time
import serial
import stats
import optparse

parser = optparse.OptionParser()

parser.add_option("-d", "--device", dest="device", type="string",
		default="/dev/ttyUSB0", help="serial port device")
parser.add_option("-b", "--baud", dest="baud", type="int",
		default=9600, help="device baud rate")
parser.add_option("-t", "--timeout", dest="timeout", type="float",
		default=0.1, help="device write timeout")
parser.add_option("-s", "--samples", dest="samples", type="int",
		default=10, help="number of smaples")
parser.add_option("-f", "--failures", dest="failures", type="int",
		default=4, help="maximum number of tolerated failures")

options, args = parser.parse_args(sys.argv)

s = serial.Serial(options.device,baudrate=options.baud, timeout=options.timeout,
		bytesize=8, parity=serial.PARITY_NONE)

time.sleep(0.001)

failed = 0
scores = list()

while len(scores) < options.samples:
	# run test and request result
	s.write("S")
	data = s.read()

	if len(data) != 1 or data != "R":
		print "test failed: no acknowledgment"
		failed += 1
		if failed >= options.failures:
			print "ERROR: maximum read failures reached"
			sys.exit(1)
		else:
			continue

	score = 0
	data = s.read(4)
	if len(data) != 4:
		print "test failed: invalid score bytes"
		failed += 1
		if failed >= options.failures:
			print "ERROR: maximum read failures reached"
			sys.exit(1)
		else:
			continue

	for value, shift in zip(data, [0, 8, 16, 24]):
		score += ord(value) << shift
	
	print "read score: %8d (0x%08X)" % (score, score)
	scores.append(score)

mean = stats.lmean(scores)
stdev = stats.lstdev(scores)
rating = mean / stdev

print "average score: %.2f" % mean
print "standard deviation: %.2f" % stdev
print "rating: %.6f" % rating

