#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/map/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 18:55:51 $
# *
# */
# file @(#)Makefile	1.3 
# last modified on 6/13/91 at 18:07:59 

# map -- mapping and library package 
#----------------------------------------------------------------------

CAD 	= /projects/octtools/octtools/mips
SIS	= ..
LINTCREATEFLAG = -C

P	= map
PSRC	= addinv.c bin_delay.c bottom_up.c chkform.c cluster.c com_map.c \
	  fanout_delay.c fanout_dump.c fanout_est.c fanout_log.c \
	  fanout_opt.c fanout_tree.c fanout_util.c gate_link.c hackit.c \
	  library.c libutil.c lt_trees.c map_delay.c map_interface.c \
	  maputil.c match.c mix_lt_trees.c multi_array.c noalg.c prim.c \
	  pwl.c replace.c top_down.c tree.c treemap.c treesize.c two_level.c \
	  virtual_del.c virtual_net.c
POBJ	= $(PSRC:.c=.o)
PHDR	= bin_int.h fanout_alg.h fanout_alg_macro.h fanout_delay.h \
	  fanout_int.h gate_link.h lib_int.h library.h map.h map_defs.h \
	  map_delay.h map_int.h map_macros.h multi_array.h pwl.h
MISC    = $(P).doc library.doc Makefile

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
LINTFLAGS = $(INCLUDE) ${LINTEXTRAS}

#----------------------------------------------------------------------

$(TARGET): $(POBJ) $(LIBS) $(PHDR)
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
	lint $(LINTFLAGS) ${LINTCREATEFLAG}$(P) -n $(PSRC)

clean:
	rm -f $(TARGET) $(TARGETPG) *.a *.ln *.o \
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
IBMHOST = ic
IBMDIST = 
ibmdist: $(PSRC) $(PHDR)
	rdist -Richw $(PSRC) $(PHDR) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:

