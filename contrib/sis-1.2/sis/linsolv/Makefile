#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/linsolv/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.1 $
# * $Date: 1994/04/20 19:38:46 $
# *
# */
# linsolv -- Sparse1.3 : A Sparse Linear Equation Solver by Ken Kundert
#---------------------------------------------------------------------------

CAD	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= linsolv
PSRC	= spAllocate.c spBuild.c spFactor.c spOutput.c spSolve.c spUtils.c
POBJ	= $(PSRC:.c=.o)
PHDR	= spConfig.h spDefs.h spMatrix.h

LIBS	= 
LINTLIBS= 
INCLUDE	= -I$(SIS)/include -I$(CAD)/include

CFLAGS	= -g $(INCLUDE)
LDFLAGS	=  -g
LINTFLAGS = $(INCLUDE) ${LINTEXTRAS}

#---------------------------------------------------------------------------

install: lib$(P).a llib-l$(P).ln

lib$(P).a: $(POBJ)
	ar cr lib$(P).a $(POBJ)
	ranlib lib$(P).a

unpack: lib$(P).a
	@for i in $(POBJ); do				\
	    ln -s $(SIS)/$(P)/$$i $(SIS)/unpack;	\
	done

llib-l$(P).ln: $(PSRC) $(PHDR)
	lint $(LINTFLAGS) ${LINTCREATEFLAG}$(P) -n $(PSRC)

lint: $(PSRC) $(PHDR) $(SRC) $(HDR)
	lint $(LINTFLAGS) $(SRC) $(PSRC) $(LINTLIBS)

clean:
	rm -f $(TARGET) *.a *.ln *.o \
	    [Tt]ags [Mm]ake.out lint malloc.out gmon.out __.SYMDEF

tags: _force
	@for i in $(PSRC) $(PHDR); do			\
	    cwd=`pwd`; ctags -a $$cwd/$$i;		\
	done;

strip_depend:
	sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile >mktemp
	mv mktemp Makefile

depend:
	sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile >mktemp
	echo '#--DO NOT CHANGE ANYTHING AFTER THIS LINE' >>mktemp
	$(CAD)/bin/cc-M $(CFLAGS) $(PSRC) | \
	    sed 's|$(CAD)|$$(CAD)|g' | \
	    grep -v '/usr/include' >>mktemp
	mv mktemp Makefile

_force:

