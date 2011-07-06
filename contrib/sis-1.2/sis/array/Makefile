#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/array/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.3 $
# * $Date: 1994/07/15 22:56:23 $
# *
# */
# array -- dynamic array package
#---------------------------------------------------------------------------

CAD	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= array
PSRC	= array.c
POBJ	= $(PSRC:.c=.o)
PHDR	= array.h
MISC	= array.doc Makefile arr_main.c

TARGET	= a.out
SRC	= arr_main.c
OBJ	= arr_main.o
HDR	=

LIBS	= ../util/libutil.a
LINTLIBS= ../util/llib-lutil.ln
INCLUDE	= -I$(SIS)/include -I$(CAD)/include

CFLAGS	= $(INCLUDE)
LDFLAGS	= 
LINTFLAGS = $(INCLUDE) ${LINTEXTRAS}

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

depend:
	sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile >mktemp
	echo '#--DO NOT CHANGE ANYTHING AFTER THIS LINE' >>mktemp
	$(CAD)/bin/cc-M $(CFLAGS) $(PSRC) | \
	    sed 's|$(CAD)|$$(CAD)|g' | \
	    grep -v '/usr/include' >>mktemp
	mv mktemp Makefile

strip_depend:
	sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile >mktemp
	mv mktemp Makefile
_force:

