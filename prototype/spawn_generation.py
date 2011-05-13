#!/usr/bin/env python2

import sys
import os
import optparse
import glob
import re
import threading
import shutil

import util

GENERATION = "g%06d"
INDIVIDUAL = "i%04d"


def generate_individual(num, base, scripts):
	# create unique folder
	name = INDIVIDUAL % num
	folder = base + "/" + name
	os.mkdir(folder)
	os.chdir(folder)

	# move seed file if it exists
	if os.path.exists("%s.seed" % name):
		os.rename("%s.seed" % name, "%s/individual.seed" % name)

	# generate individual
	result = util.execute("%s/generate.csh" % scripts, redirect="generate.log")

	# delete the databases
	shutil.rmtree("db", True)
	shutil.rmtree("incremental_db", True)

	# save output files
	os.chdir(base)
	if result == 0:
		for ext in ["csv", "sof"]:
			os.rename("%s/individual.%s" % (name, ext), "%s.%s" % (name, ext))

	# compress any interesting files
	util.execute("tar czf %s.tgz %s" % (name, name))
	shutil.rmtree(name)

	return result



def test_individual(sof, board, interface, scripts):
	print "testing " + sof

	# program
	if util.execute("quartus_pgm -c %d -m JTAG -o P;%s" % \
			(board, sof), redirect="quartus.pgm.log", append=True) != 0:
		print "programming failed"

	# test
	else:
		score = re.sub("\.sof$", ".score", sof)
		if util.execute("%s/read_score.py -d %s -o %s" % \
				(scripts, interface, score),
				redirect="read_score.log", append=True) != 0:
			print "testing failed"



def run_process(number, total, population, base, scripts):
	for i in range(number, population, total):
		generate_individual(i, base, scripts)



def main():
	parser = optparse.OptionParser()

	parser.add_option("-g", "--generation", dest="generation", type="int", 
			default=0, help="generation to spawn (generation 0 is fully random)")

	parser.add_option("-f", "--folder", dest="folder", type="string",
			default="run", help="folder to create generation in")
	
	parser.add_option("-n", "--population", dest="population", type="int",
			default=20, help="population size")

	parser.add_option("-p", "--processes", dest="processes", type="int",
			default=1, help="number of processes to use")

	parser.add_option("-d", "--dry", dest="dry", action="store_true",
			help="spawn generation without programming/testing")

	options, args = parser.parse_args(sys.argv)

	# make base folder for this generation
	initial = os.getcwd()
	base = ("%s/%s/" + GENERATION) % (initial, options.folder, options.generation)
	util.makepath(base, delete=True)
	os.chdir(base)

	# get or set environment variable for the scripts path
	scripts = util.setenv("EVOLUTION_SCRIPTS", initial)
	
	# get or set environment variable for verilog folder path
	verilog = util.setenv("EVOLUTION_VERILOG", initial + "/verilog")
	
	# create seeds from previous generation
	if options.generation > 0:
		prev = options.generation - 1
		print "creating seeds from generation", prev
		inputs = glob.glob((INDIVIDUAL % prev) + re.sub("%.*", ".csv", INDIVIDUAL))
		
		if len(inputs) == 0:
			print "ERROR: no seeds available in generation", prev
			sys.exit(1)

		for i in range(options.population):
			in1 = random.choice(inputs)
			in2 = random.choice(inputs)
			out = (INDIVIDUAL + ".seed") % i
			util.execute("%s/merge_individuals.py %s %s %s" % \
					(scripts, in1, in2, out), redirect="merge.log")

	# don't test individuals in the generate script
	os.unsetenv("EVOLUTION_RUN")

	print "generating", options.population, "individuals"

	# run processes
	if options.processes > 1:
		# create that many processes
		print "creating", options.processes, "parallel processes"
		pids = list()
		for i in range(options.processes):
			pid = os.fork()
			if pid > 0:
				pids.append(pid)
			else:
				run_process(i, options.processes, options.population, base, scripts)
				sys.exit(0)

		# wait for all processes to return
		for pid in pids:
			os.waitpid(pid, 0)

	else:
		# just run it directly if there's only one thread
		run_thread(0, 1, options.population, base, scripts)
	
	outputs = glob.glob(re.sub("%.*", "*.sof", INDIVIDUAL))

	print "%d/%d individuals were generated sucessfully" % \
			(len(outputs), options.population)

	if options.dry:
		return
	
	for sof in outputs:
		test_individual(sof, 1, "/dev/ttyUSB0", scripts)



if __name__ == "__main__":
	main()

