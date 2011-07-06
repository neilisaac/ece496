#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/graph/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 18:54:12 $
# *
# */
# graph -- generic graph and static graph packages
#----------------------------------------------------------------------

CAD 	= /projects/octools/octtools/$(MACHINE)
SIS	= ..
LINTCREATEFLAG = -C

P	= graph
PSRC	= graph.c graph_s.c com_graph.c graph_dfs.c
POBJ	= $(PSRC:.c=.o)
PHDR	= graph.h graph_int.h graph_static.h graph_static_int.h
MISC	= $(P).doc graph-static.doc Makefile

TARGET	= a.out

LIBS	= ../util/libutil.a ../graph/libgraph.a
LINTLIBS= ../util/llib-lutil.ln ../graph/llib-lgraph.ln
INCLUDE	= -I$(SIS)/include -I$(CAD)/include 

CFLAGS	= -g $(INCLUDE) -DSIS
LDFLAGS	= -g
LINTFLAGS = $(INCLUDE)

#-------------------------------------------------

$(TARGET): $(POBJ) $(LIBS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(POBJ) $(LIBS)

lint: $(PSRC) $(PHDR)
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
IBMHOST = opua
IBMDIST = /users2/sis
IBMSRC = $(PSRC) $(PHDR) eqnlex.c 
ibmdist: $(IBMSRC) 
	rdist -Richw $(IBMSRC) $(IBMHOST):$(IBMDIST)
#-------------------------------------------------------------
_force:

