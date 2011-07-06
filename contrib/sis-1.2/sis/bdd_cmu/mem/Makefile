# name of this package
NAME = mem

# source files
SRC = memblock.c  memrec.c
HDR = memuser.h memint.h
MISC = mem.3 Makefile

# search path for source files, separated by ":"
VPATH = $(CURRENT)/src/bdd_cmu/mem:$(CURRENT)/include

# include file for building object libraries
include $(CURRENT)/Make_lib.include

# dependencies
memblock.o : memblock.c memint.h memuser.h 
memrec.o: memrec.c memint.h memuser.h 
