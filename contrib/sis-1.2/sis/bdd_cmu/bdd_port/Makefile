# name of this package
NAME = bdd_port
CURRENT = /projects/sis/sis-devel/common/src/sis/bdd_cmu

# source files
SRC = bddport.c bdditer.c
HDR = bdd.h
MISC = Makefile 

VPATH = $(CURRENT)/bdd_cmu/$(NAME):../bdd_cmu:$(CURRENT)/src/bdd_cmu/bdd_cmu:\
	../mem:$(CURRENT)/src/bdd_cmu/mem:$(CURRENT)/include:$(SIS)/include

# include file for building object libaries
include $(CURRENT)/Make_lib.include

# need to overwrite the value for INCLUDE given in Make_lib.include,
# because we need bdd_cmu/bddint.h
INCLUDE = -I. -I../bdd_cmu -I../mem -I$(CURRENT)/include -I$(SIS)/include
