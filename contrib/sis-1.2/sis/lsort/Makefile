#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/lsort/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 19:06:01 $
# *
# */
# lsort: generic linked list sorter
#---------------------------------------------------------------------------

CAD	= /projects/octtools/octtools/octtools/$(MACHINE)

LINTCREATEFLAG = -C

P	= lsort
SRC	= lsort.c
OBJ	= lsort.o
HDR	= lsort.h luniq.h

PHDR	= lsort.h luniq.h
MISC	= Makefile

LIBS	= ../util/libutil.a
LINTLIBS= ../util/llib-lutil.ln
INCLUDE	= -I$(SIS)/include -I$(CAD)/include

CFLAGS = -g $(INCLUDE)
LINTFLAGS =  $(INCLUDE) ${LINTEXTRAS}

#---------------------------------------------------------------------------

install:

lsort: $(OBJ) $(LIBS)
	$(CC) $(CFLAGS) -o lsort $(OBJ) $(LIBS)

test: lsort
	echo "random order" >test
	lsort -n 10000 -b 10000 >>test
	echo "initial in order" >>test
	lsort -o -n 10000 >>test
	echo "initial in reverse order" >>test
	lsort -r -n 10000 >>test

lint: $(SRC) $(HDR)
	lint $(LINTFLAGS) lsort.c >lint

clean:
	rm -f lsort $(OBJ) [Tt]ags [Mm]ake.out lint test

tags: $(SRC) $(HDR)
	ctags $(SRC) $(HDR)

strip_depend:
	sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile >mktemp
	mv mktemp Makefile

depend:
	sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile >mktemp
	echo '#--DO NOT CHANGE ANYTHING AFTER THIS LINE' >>mktemp
	$(CAD)/bin/cc-M $(CFLAGS) $(SRC) | \
	    sed 's|$(CAD)|$$(CAD)|g' >>mktemp
	mv mktemp Makefile

#-------------------------- IBM 3090 support -----------------
IBMHOST	= opua
IBMDIST	= /users2/sis
ibmdist: $(PSRC) $(PHDR)
	rdist -Richw $(PSRC) $(PHDR) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
#--DO NOT CHANGE ANYTHING AFTER THIS LINE
