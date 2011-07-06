#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/mincov/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 18:57:09 $
# *
# */
# mincov -- weighted minimum cover package
#---------------------------------------------------------------------------

CAD	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= mincov
PSRC	= mincov.c solution.c gimpel.c indep.c dominate.c part.c \
	  bin_mincov.c bin_sol.c
POBJ	= $(PSRC:.c=.o)
PHDR	= mincov.h mincov_int.h 
MISC	= $(P).doc Makefile main.c

TARGET	= mincov
SRC	= main.c
OBJ	= main.o
HDR	=

INCLUDE	= -I$(SIS)/include -I$(CAD)/include

LIBS	= ../sparse/libsparse.a 	\
	  ../util/libutil.a

LINTLIBS= ../sparse/llib-lsparse.ln 	\
	  ../util/llib-lutil.ln 

CFLAGS	= -O $(INCLUDE)
LDFLAGS	=
LINTFLAGS =  $(INCLUDE) ${LINTEXTRAS}

#---------------------------------------------------------------------------

$(TARGET): $(PHDR) $(OBJ) $(POBJ) $(LIBS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJ) $(POBJ) $(LIBS)

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
