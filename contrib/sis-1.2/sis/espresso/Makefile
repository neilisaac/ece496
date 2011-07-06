#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/espresso/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 18:52:21 $
# *
# */
# espresso
#---------------------------------------------------------------------------

CAD	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= espresso
PSRC	= cofactor.c compl.c contain.c cubestr.c cvrin.c cvrm.c\
	  cvrmisc.c cvrout.c equiv.c espresso.c essen.c exact.c\
	  expand.c gasp.c globals.c hack.c irred.c map.c opo.c\
	  pair.c primes.c reduce.c set.c setc.c sharp.c sminterf.c\
	  sparse.c unate.c verify.c
POBJ	= $(PSRC:.c=.o)
PHDR	= espresso.h
MISC	= Makefile

TARGET	= espresso

INCLUDE	= -I$(SIS)/include -I$(CAD)/include

CFLAGS	= -g $(INCLUDE)
LDFLAGS	=
LINTFLAGS =  $(INCLUDE) ${LINTEXTRAS}

#---------------------------------------------------------------------------

$(TARGET): $(PHDR) $(OBJ) $(LIBS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJ) $(LIBS)

lint: $(PSRC) $(PHDR) $(SRC) $(HDR)
	lint $(LINTFLAGS) $(SRC) $(PSRC) $(LINTLIBS)

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

clean:
	rm -f *.a *.ln *.o $(TARGET) \
	    [Tt]ags [Mm]ake.out malloc.out gmon.out lint

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

#-------------------------- IBM 3090 support -----------------
IBMHOST	= opua
IBMDIST	= /users2/sis
ibmdist: $(PSRC) $(PHDR)
	rdist -Richw $(PSRC) $(PHDR) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:
