#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.4 $
# * $Date: 1994/07/15 22:58:43 $
# *
# */
#
# Makefile for STAMINA0.0
#

MACHINE = VAX
LIBDIR = ../lib
BINDIR = ../bin
CC = cc

all:
	rm -rf lib/$(MACHINE)
	mkdir lib/$(MACHINE)
	cd hash; make CC=$(CC) SIS=$(SIS) libhash.a ; cp libhash.a $(LIBDIR)/$(MACHINE)
	cd mimi; make CC=$(CC) SIS=$(SIS) install "MACHINE=$(MACHINE)" "INSDIR=$(BINDIR)"

clean:
	cd hash; make clean; cd ..
	cd mimi; make clean; cd ..

cleanall: clean
	rm -rf lib/*
	rm -rf bin/stamina

ci_rcs:
	ci $(CI_FLAGS) Makefile stamina.1
	(cd hash; ci $(CI_FLAGS) Makefile README *.c *.h)
	(cd mimi; ci $(CI_FLAGS) Makefile *.c *.h)

rm_rcs:
	rm -rf RCS
	rm -rf hash/RCS mimi/RCS
