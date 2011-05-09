#!/usr/bin/env python2

import sys
import os
import optparse
import glob
import re
import threading

import util

GENERATION = "g%06d"
INDIVIDUAL = "i%04d"


def generate_individual(num, base, scripts):
	# create unique folder
	individual = INDIVIDUAL % num
	folder = base + "/" + individual
	os.mkdir(folder)
	os.chdir(folder)

	# generate individual
	result = util.execute("%s/generate.csh" % scripts)

	# save output files
	os.chdir(base)
	if result == 0:
		for ext in ["csv", "sof"]:
			os.rename("%s/individual.%s" % (individual, ext), "%s.%s" % (individual, ext))

	# compress other interesting files
	files = " ".join(glob.glob("%s/individual.*" % individual))
	util.execute("tar czf %s.tgz %s" % (individual, files))

	# delete the rest
	#util.execute("rm -rf %s" % folder)

	return result



def run_thread(number, total, population, base, scripts):
	for i in range(number, population, total):
		generate_individual(i, base, scripts)



def main():
	parser = optparse.OptionParser()

	parser.add_option("-g", "--generation", dest="generation", type="int", 
			default=0, help="generation to spawn (generation 0 is fully random)")

	parser.add_option("-f", "--folder", dest="folder", type="string",
			default="run", help="folder to create generation in")
	
	parser.add_option("-p", "--population", dest="population", type="int",
			default=20, help="population size")

	parser.add_option("-t", "--threads", dest="threads", type="int",
			default=1, help="number of threads to use")

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

	# TODO: generate seeds if generation > 1

	# don't test individuals in the generate script
	os.unsetenv("EVOLUTION_RUN")

	# run threads
	if options.threads > 1:
		# create that many threads
		threads = list()
		for i in range(options.threads):
			args = (i, options.threads, options.population, base, scripts)
			thread = threading.Thread(target=run_thread, args=args)
			thread.start()
			threads.append((i, thread))

		# wait for all threads to complete
		while len(threads) > 0:
			for obj in threads:
				num, thread = obj
				thread.join(1)
				if thread.is_alive():
					continue
				
				print "generated individual", num
				threads.remove(obj)
				break

	else:
		# just run it directly if there's only one thread
		run_thread(0, 1, options.population, base, scripts)
	
	outputs = glob.glob(re.sub("%.*", "*.sof", INDIVIDUAL))

	print "%d/%d individuals were generated sucessfully" % \
			(len(outputs), options.population)
	
	for sof in outputs:
		print "testing " + sof

		# program
		if util.execute("quartus_pgm -c %d -m JTAG -o P;%s" % \
				(1, sof), redirect="quartus.pgm.log", append=True) != 0:
			print "programming failed"

		# test
		else:
			score = re.sub("\.sof$", ".score", sof)
			if util.execute("%s/read_score.py -d %s -o %s" % \
					(scripts, "/dev/ttyUSB0", score),
					redirect="read_score.log", append=True) != 0:
				print "testing failed"



if __name__ == "__main__":
	main()

