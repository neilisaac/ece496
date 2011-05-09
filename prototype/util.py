import os
import shutil

def execute(cmd, wait=True, args=None):
	''' fork and exec to run a given command '''

	cmd = cmd.split()
	if args is not None:
		cmd.extend(args)

	pid = os.fork()
	if pid > 0:
		if wait:
			pid, exit = os.waitpid(pid, 0)
			return exit
		else:
			return 0
	else:
		os.execvp(cmd[0], cmd)
	
	raise Exception, "fork or exec call malfunctioned"



def makepath(path, delete=False):
	''' create the a folder hierarchy for path '''

	if delete and os.path.exists(path):
		shutil.rmtree(path)

	if not os.path.exists(path) or not os.path.isdir(path):
		os.makedirs(path)



def setenv(name, value):
	current = os.getenv(name)
	if current is not None:
		return current
	else:
		os.putenv(name, value)
		return value

