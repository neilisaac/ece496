#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/io/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 18:54:43 $
# *
# */
# io -- read/write utilities and commands
#----------------------------------------------------------------------

CAD 	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= io
PSRC	= com_io.c plot_blif.c read_blif.c read_eqn.c read_kiss.c \
          read_pla.c read_slif.c read_util.c \
	  write_bdnet.c write_blif.c write_eqn.c write_kiss.c \
	  write_pla.c write_slif.c write_util.c 
POBJ	= $(PSRC:.c=.o)
PHDR	= io.h io_int.h
MISC	= $(P).doc Makefile eqnlex.l read_eqn.y

TARGET	= sis

LIBS	= $(SIS)/lib/libsis.a \
	  $(CAD)/lib/liboh.a \
	  $(CAD)/lib/liboct.a \
	  $(CAD)/lib/libst.a \
	  $(CAD)/lib/libtr.a \
	  $(CAD)/lib/libmm.a \
	  $(CAD)/lib/liberrtrap.a \
	  $(CAD)/lib/libuprintf.a \
	  $(CAD)/lib/libutility.a \
	  $(CAD)/lib/libport.a \
	  $(CAD)/lib/libpq.a \
	  $(CAD)/lib/libda.a

LIBSG	= $(SIS)/lib/libsis-g.a \
	  $(CAD)/lib/liboh-g.a \
	  $(CAD)/lib/liboct-g.a \
	  $(CAD)/lib/libst-g.a \
	  $(CAD)/lib/libtr-g.a \
	  $(CAD)/lib/libmm-g.a \
	  $(CAD)/lib/liberrtrap-g.a \
	  $(CAD)/lib/libuprintf-g.a \
	  $(CAD)/lib/libutility-g.a \
	  $(CAD)/lib/libport-g.a \
	  $(CAD)/lib/libpq-g.a \
	  $(CAD)/lib/libda-g.a

LINTLIBS= $(SIS)/lib/llib-lsis.ln \
	  $(CAD)/lib/llib-loct.ln

INCLUDE	= -I$(SIS)/include -I$(CAD)/include 
CFLAGS	= -g $(INCLUDE) -DSIS
LDFLAGS	= -g
LINTFLAGS = $(INCLUDE)


#----------------------------------------------------------------------
foo: $(TARGET)

read_eqn.c: read_eqn.y
	yacc read_eqn.y
	sed < y.tab.c > read_eqn.c 's/yy/EQN_yy/g'
	rm -f y.tab.c
eqnlex.c: eqnlex.l
	lex eqnlex.l
	sed < lex.yy.c > eqnlex.c 's/yy/EQN_yy/g'
	rm -f lex.yy.c
read_eqn.o: read_eqn.c eqnlex.c
	$(CC) -c $(CFLAGS) read_eqn.c
	
#----------------------------------------------------------------------

$(TARGET): $(PHDR) $(POBJ) $(LIBS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(POBJ) $(LIBS) -lm

lint: $(PSRC) $(PHDR) $(HDR)
	lint $(LINTFLAGS) $(PSRC) $(LINTLIBS)

install: lib$(P).a llib-l$(P).ln

lib$(P).a: $(POBJ)
	@rm -f lib$(P).a
	ar cr lib$(P).a $(POBJ)
	ranlib lib$(P).a

unpack: lib$(P).a
	@for i in $(POBJ); do				\
	    ln -s $(SIS)/$(P)/$$i $(SIS)/unpack;	\
	done

llib-l$(P).ln: $(PSRC) $(PHDR)
	lint $(INCLUDE) $(LINTEXTRAS) $(LINTCREATEFLAG)$(P) -n $(PSRC)

clean:
	rm -f $(TARGET) *.a *.ln *.o \
	    [Tt]ags [Mm]ake.out malloc.out gmon.out lint read_eqn.c eqnlex.c

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
IBMHOST = ic
IBMDIST = 
IBMSRC = $(PSRC) $(PHDR) eqnlex.c 
ibmdist: $(IBMSRC) 
	rdist -Richw $(IBMSRC) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:

