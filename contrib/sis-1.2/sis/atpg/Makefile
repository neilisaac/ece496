#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/atpg/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1994/07/15 23:00:23 $
# *
# */
# atpg - ATPG package based on SAT
#----------------------------------------------------------------------

CAD 	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= atpg
PSRC	= atpg_clauses.c atpg_comb.c atpg_faults.c atpg_faultsim.c \
	  atpg_gen_test.c atpg_init.c atpg_seq.c atpg_seq_util.c \
	  atpg_util.c com_atpg.c com_redund.c com_short_t.c \
	  fast_avl.c sat.c 
POBJ	= $(PSRC:.c=.o)
PHDR	= atpg.h atpg_int.h sat.h sat_int.h fast_avl.h
MISC	= $(P).doc Makefile

TARGET	= sis

LIBS    = $(SIS)/lib/libsis.a \
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

LIBSG   = $(SIS)/lib/libsis-g.a \
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
CFLAGS = -g $(INCLUDE) -DSIS
LDFLAGS	= -g
LINTFLAGS = $(INCLUDE) $(LINTEXTRAS)

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
	@for i in $(POBJ); do                           \
	    ln -s $(SIS)/$(P)/$$i $(SIS)/unpack;        \
	done

llib-l$(P).ln: $(PSRC) $(PHDR)
	lint $(INCLUDE) -C$(P) -n $(PSRC)

clean:
	rm -f $(TARGET) $(TARGETPG) *.a *.ln *.o \
	    [Tt]ags [Mm]ake.out malloc.out gmon.out lint leak

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
	cc-M $(INCLUDE) $(PSRC) >>mktemp
	mv mktemp Makefile

#-------------------------- IBM 3090 support -----------------
IBMHOST = eros
IBMDIST = /eros1/awang/sis.ibm/src
ibmdist: $(PSRC) $(PHDR)
	rdist -Richw $(PSRC) $(PHDR) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:
