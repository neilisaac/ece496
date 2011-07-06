#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/pld/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.3 $
# * $Date: 1992/05/06 18:58:49 $
# *
# */
# pld - actel and xilinx pld synthesis
#----------------------------------------------------------------------
CAD	= /projects/octtools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG	= -C

P	= pld
PSRC	= act_apply.c act_bdd.c act_bool.c act_collapse.c act_create.c \
	  act_delay.c act_dutil.c act_init.c act_ite.c act_ite_new.c \
	  act_leaf.c act_map.c act_misc.c act_order.c act_read.c \
	  act_reduce.c act_remove.c act_urp.c act_util.c \
	  com_ite.c com_pld.c \
	  ite_break.c ite_collapse.c ite_factor.c ite_imp.c \
	  ite_leaf.c ite_map.c ite_mroot.c ite_mux_net.c \
	  ite_new_map.c ite_new_urp.c \
	  ite_pld.c ite_urp.c ite_util.c pld_util.c \
          xln_ULM_util.c xln_aodecomp.c xln_aux.c xln_collapse.c \
	  xln_cube.c xln_dec_merge.c xln_feasible.c xln_filter.c \
	  xln_imp.c xln_k_de_area.c xln_k_decomp.c xln_level.c \
	  xln_lindo.c xln_map_par.c xln_merge.c xln_move_d.c \
	  xln_new_part.c xln_part_dec.c xln_ufind.c
POBJ	= $(PSRC:.c=.o)
PHDR	= act_bool.h ite_int.h pld.h pld_int.h 
MISC    = $(P).doc Makefile

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

LINTLIBS= $(SIS)/lib/llib-lsis.ln	\
	  $(CAD)/lib/llib-loct.ln

INCLUDE	= -I$(SIS)/include -I$(CAD)/include
CFLAGS	= -g $(INCLUDE) -DSIS
LDFLAGS	= -g
LINTFLAGS = $(INCLUDE) ${LINTEXTRAS}

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
	@for i in $(POBJ); do			\
		ln -s $(SIS)/$(P)/$$i $(SIS)/unpack;	\
	done

llib-l$(P).ln: $(PSRC) $(PHDR)
	lint $(LINTFLAGS) ${LINTCREATEFLAG}$(P) -n $(PSRC)

clean:
	rm -f $(TARGET) $(TARGETPG) *.a *.ln *.o \
	    [Tt]ags [Mm]ake.out malloc.out gmon.out lint .saberinit \
	    leak profile

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
	$(CAD)/bin/cc-M $(INCLUDE) $(PSRC) | \
	    sed 's|$(CAD)|$$(CAD)|g' | \
	    grep -v '/usr/include' >>mktemp
	mv mktemp Makefile

#-------------------------- IBM 3090 support -----------------
IBMHOST	= beeblebrox
IBMDIST	= /net/beeblebrox/misII/vax/src
#ibmdist: $(PSRC) $(PHDR)
#	rdist -Richw $(PSRC) $(PHDR) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:

