#!/usr/bin/env python2.7

from collections import deque

def tokenize(filename, startcomments=True, midcomments=True):
	lines = deque()
	stream = open(filename)
	
	concat = False
	for line in stream.readlines():
		if len(line) == 0:
			continue

		# remove comments if desired
		if startcomments and line[0] == '#':
			continue
		elif midcomments and '#' in line:
			line = line.split('#')[0]

		concatnext = False
		tokens = line.split()
		if len(tokens) > 0 and tokens[-1] == "\\":
			concatnext = True
			tokens = tokens[:-1]
		if concat:
			lines[-1].extend(tokens)
		else:
			lines.append(tokens)
		concat = concatnext

	return lines


if __name__ == "__main__":
	import sys
	
	if len(sys.argv) != 2:
		print "usage:", sys.argv[0], "<file>"
		sys.exit(1)
	
	for line in tokenize(sys.argv[1]):
		print line

