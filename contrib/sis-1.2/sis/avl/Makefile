#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/avl/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.3 $
# * $Date: 1994/07/15 23:00:40 $
# *
# */
# avl -- balanced binary tree package
#---------------------------------------------------------------------------

CAD	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= avl
PSRC	= avl.c
POBJ	= $(PSRC:.c=.o)
PHDR	= avl.h
MISC	= $(P).doc Makefile avl_bench1.c

TARGET	= avl_bench1
SRC	= avl_bench1.c
OBJ	= avl_bench1.o
HDR	=

LIBS	= ../util/libutil.a ../array/libarray.a
LINTLIBS= ../util/llib-lutil.ln ../array/llib-larray.ln
INCLUDE	= -I$(SIS)/include -I$(CAD)/include

CFLAGS	= -g $(INCLUDE)
LDFLAGS	= -g
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

#-------------------------- IBM 3090 support -----------------
IBMHOST	= opua
IBMDIST	= /users2/sis
ibmdist: $(PSRC) $(PHDR)
	rdist -Richw $(PSRC) $(PHDR) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:

