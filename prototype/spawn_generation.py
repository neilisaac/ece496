#!/usr/bin/env python2

import sys
import os
import optparse
import glob
import util

def main():
	parser = optparse.OptionParser()

	parser.add_option("-g", "--generation", dest="generation", type="int", 
			default=0, help="generation to spawn (generation 0 is fully random)")

	parser.add_option("-f", "--folder", dest="folder", type="string",
			default="run", help="folder to create generation in")
	
	parser.add_option("-p", "--population", dest="population", type="int",
			default=20, help="population size")

	parser.add_option("-k", "--processes", dest="processes", type="int",
			default=1, help="number of processes to fork")

	parser.add_option("-n", "--process-num", dest="number", type="int",
			default=0, help="process number")

	options, args = parser.parse_args(sys.argv)

	# TODO: use arguments (processes, number)

	# make base folder for this generation
	initial = os.getcwd()
	base = "%s/%s/generation%05d" % (initial, options.folder, options.generation)
	util.makepath(base)

	# get or set environment variable for the scripts path
	scripts = util.setenv("EVOLUTION_SCRIPTS", initial)
	
	# get or set environment variable for verilog folder path
	verilog = util.setenv("EVOLUTION_VERILOG", initial + "/verilog")

	# test individuals after compiling (single-process only)
	os.putenv("EVOLUTION_RUN", "1")
	
	# TODO: generate seeds if generation > 1

	# compile an individual in its own folder
	for num in range(options.population):
		# generate individual
		individual = "%s/individual%04d" % (base, num)
		util.makepath(individual, delete=True)
		os.chdir(individual)
		util.execute("%s/generate.csh" % scripts)

		# clean up
		os.chdir(base)
		files = " ".join(glob.glob("individual%04d/individual.*" % num))
		util.execute("tar czf individual%04d.tgz %s" % (num, files))
		util.execute("cp individual%04d/individual.score individual%04d.score" % (num, num))
		#util.execute("rm -rf individual%04d" % num)

	os.chdir(initial)



if __name__ == "__main__":
	main()

