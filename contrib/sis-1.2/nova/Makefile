#/*
# * Revision Control Information
# *
# * $Source$
# * $Author$
# * $Revision$
# * $Date$
# *
# */
#
#  Octtools Makefile
#
#  nova - State assignment for PLA-based finite state machines
#
#  Makefile created on Thu Mar 7 09:59:16 PST 1991 by octtools (using 'create-octtools-makefile')
#
#  Copyright (c) 1988, 1989, 1990, Regents of the University of California
#
#
# Description of the 'targets': say "make help"
#
# Description of the 'variables':
#
#  BUILD:		name of the program that builds a 'Makefile' from
#				'Makefile.template'
#  OCTTOOLS:		location of the OctTools
#  CADROOT:		run-time location of the CAD libraries (can have '~')
#  CC:			name of the C-compiler
#  OPTFLAG:		optimization level (usually nothing, -O, or -O#)
#  DBGFLAG:		debug level (usually nothing, -g, or -pg)
#  RDFLAGS:		flags to rdist (e.g., -Rich)
#  CP:			name of the program used for installation
#  LDFLAGS:		flags used for linking (e.g., -lXMenu -lX -lm)
#  LINTCREATEFLAG:	flag used by 'lint' for creating lint libraries
#			(-C for BSD, ULTRIX, SUN; -o for IBM RT/PC, ULTRIX/RISC)
#  P:			either nothing or & - used by the sequent to
#				parallelize compiles
#  PRINTER:		name of the printer
#  SHELL:		shell used by 'make' (should always be the bourne shell)
#
#
#------------------------------------------------------------------------------
.SUFFIXES: .c .y .l .cc .o

.cc.o:
	${CPLUSPLUS} ${CFLAGS} -c $*.cc

# for HPUX
SHELL	= /bin/sh

MAKE = /bin/make
AR = ar
RANLIB = ranlib
CPLUSPLUS = g++

CAD	= /projects/octtools/octtools/${MACHINE}
OCTTOOLS= ${CAD}
CADROOT	= $$OCTTOOLS
UTILS	= ${OCTTOOLS}/utils
XINCLOC = -I/usr/local/X11R4/include
XLIBLOC = -L/usr/local/X11R4/lib

LINTCREATEFLAG = -C
LINTEXTRAS =
DBGFLAG =
OPTFLAG =

# an alternative if you want links in the installation locations
# back to the source directories would be:
#   CP = sh -c 'ln -s `pwd`/$$0 $$1'
CP = cp

BUILD = ${OCTTOOLS}/bin/create-octtools-makefile

# cute hack for the sequent
#   setenv PARALLEL 8; make P="&" install
P = 

NAME	= nova

# packages required for this package/tool
REQUIRE	= 

# tools required for this tool
TOOLREQUIRE = 

SRC	= alloc.c anneal_code.c auxil.c coloring.c comb_objects.c exact_backtrack.c exact_code.c exact_graph.c exact_lbound.c exact_mini.c exact_output.c get_constr.c ihybrid_code.c input_fsm.c iohybrid_code.c iovariant_code.c log_approx.c log_code.c log_mini.c log_output.c log_precode.c log_sel.c lower_bound.c nova.c nova_summ.c options.c out_encoder.c out_eval.c show.c symbolic_loop.c user_codes.c
LSRC	= alloc.c anneal_code.c auxil.c coloring.c comb_objects.c exact_backtrack.c exact_code.c exact_graph.c exact_lbound.c exact_mini.c exact_output.c get_constr.c ihybrid_code.c input_fsm.c iohybrid_code.c iovariant_code.c log_approx.c log_code.c log_mini.c log_output.c log_precode.c log_sel.c lower_bound.c nova.c nova_summ.c options.c out_encoder.c out_eval.c show.c symbolic_loop.c user_codes.c
OBJ	= alloc.o anneal_code.o auxil.o coloring.o comb_objects.o exact_backtrack.o exact_code.o exact_graph.o exact_lbound.o exact_mini.o exact_output.o get_constr.o ihybrid_code.o input_fsm.o iohybrid_code.o iovariant_code.o log_approx.o log_code.o log_mini.o log_output.o log_precode.o log_sel.o lower_bound.o nova.o nova_summ.o options.o out_encoder.o out_eval.o show.o symbolic_loop.o user_codes.o
HDR	= espresso.h nova.h out_encoder.h decls.h

CADBIN	= ${OCTTOOLS}/bin

TOOLINSTALL= ${CADBIN}/${TARGET} ${OCTTOOLS}/man/man1/${MAN}
INSTALL	= ${PKGINSTALL} ${TOOLINSTALL} 

DISTDEST= ${OCTTOOLS}/src/${NAME}
DISTHOST= BOGUS-HOST
MISC	= Makefile Makefile.template test.kiss2 test.out

#LIBS	= $(SIS)/libsis.a $(OCTTOOLS)/lib/liboh$(DBGFLAG).a $(OCTTOOLS)/lib/liboct$(DBGFLAG).a $(OCTTOOLS)/lib/libtr$(DBGFLAG).a $(OCTTOOLS)/lib/libvov$(DBGFLAG).a $(OCTTOOLS)/lib/libutility$(DBGFLAG).a $(OCTTOOLS)/lib/libst$(DBGFLAG).a $(OCTTOOLS)/lib/libmm$(DBGFLAG).a $(OCTTOOLS)/lib/liberrtrap$(DBGFLAG).a $(OCTTOOLS)/lib/libuprintf$(DBGFLAG).a $(OCTTOOLS)/lib/libport$(DBGFLAG).a
LIBS	= $(SIS)/lib/libsis.a
LINTLIBS= $(OCTTOOLS)/lib/llib-lmisII.ln $(OCTTOOLS)/lib/llib-lmm.ln $(OCTTOOLS)/lib/llib-lport.ln

TARGET	= ${NAME}
TARGETG	= ${NAME}-g
TARGETPG	= ${NAME}-pg
MAN	= ${NAME}.1

PRINTER	= lps40
MACROS	= -man.4.3
PRINT	= lpr
TROFF	= ptroff
TBL	= tbl

MAKEVARS =	\
		"CAD=${CAD}" \
		"CADROOT=${CADROOT}" \
		"CC=${CC}" \
		"OPTFLAG=${OPTFLAG}" \
		"DBGFLAG=${DBGFLAG}" \
		"RDFLAGS=${RDFLAGS}" \
		"CP=${CP}" \
		"LINTCREATEFLAG=${LINTCREATEFLAG}" \
		"LINTEXTRAS=${LINTEXTRAS}" \
		"MAKE=$(MAKE)" \
		"MACROS=${MACROS}" \
		"P=${P}" \
		"PRINT=${PRINT}" \
		"PRINTER=${PRINTER}" \
		"TBL=${TBL}" \
		"TROFF=${TROFF}" \
		"AR=${AR}" \
		"RANLIB=${RANLIB}" \
		"CPLUSPLUS=${CPLUSPLUS}" \
		"XINCLOC=${XINCLOC}" \
		"XLIBLOC=${XLIBLOC}" \
		"VPATH=${VPATH}"

INCLUDE	= ${XINCLOC}  -I${OCTTOOLS}/include
CFLAGS	= ${OPTFLAG} ${DBGFLAG} ${INCLUDE} '-DCADROOT="$$OCTTOOLS"'
VERSION	= "-DCUR_DATE=\"`date | awk '{print $$2, $$3, $$6}'`\"" \
	  "-DCUR_TIME=\"`date | awk '{print $$4}'`\""
LINTFLAGS= ${INCLUDE} '-DCADROOT="${CADROOT}"' ${LINTEXTRAS}
LDFLAGS	= ${XLIBLOC}  -lm
RDFLAGS    = -Rich
#-----------------------------------------------------------------------

prog: ${TARGET}

all: tags lint ${TARGET}

build: Makefile.template
	${BUILD} Makefile.template

install: ${INSTALL}
install.lint: ${LINTINSTALL}

uninstall:
	rm -rf ${INSTALL}

version.o: version.c
	${CC} ${CFLAGS} ${VERSION} -c version.c
	-touch -f version.c

debug: debug-g debug-pg


debug-g:
	rm -f ${OBJ}
	$(MAKE) $(MFLAGS) DBGFLAG=-g $(MAKEVARS) ${TARGETG}

debug-pg:
	rm -f ${OBJ}
	$(MAKE) $(MFLAGS) DBGFLAG=-pg $(MAKEVARS) ${TARGETPG}



${TARGET} ${TARGETG} ${TARGETPG}:${P} ${OBJ} ${LIBS}
	${CC} ${OPTFLAG} ${DBGFLAG} -o $@ ${OBJ} ${LIBS} ${LDFLAGS}


header::

${CADBIN}/${TARGET}: ${TARGET}
	rm -f $@
	${CP} $? $@
	strip $@

${OCTTOOLS}/man/man1/${MAN}: ${MAN}
	rm -f $@
	${TBL} < $? > $@

lint: ${LSRC} ${DRVRSRC} ${HDR} ${LINTLIBS}
	lint ${LINTFLAGS} ${LSRC} ${DRVRSRC} ${LINTLIBS} ${LDFLAGS} | tee lint

clean::
	rm -f ${OBJ} ${DRVROBJ} ${TARGET} ${TARGETG} ${TARGETPG} ${DRIVER} 
	rm -f tags TAGS ${LIB} ${LIBG} ${LIBPG} ${LINTLIB} lint 
	rm -f make.out mktemp core .p .pg *~ __________ELEL_

require:
	@echo ${REQUIRE}

help:
	@cat ${OCTTOOLS}/lib/utils/Makefile.help

toolrequire:
	@echo ${TOOLREQUIRE}

test::
	@test -f ${CADBIN}/${TARGET}

tags: ${LSRC} ${DRVRSRC} ${HDR}
	ctags ${LSRC} ${DRVRSRC} ${HDR}

TAGS: ${LSRC} ${DRVRSRC} ${HDR}
	etags ${LSRC} ${DRVRSRC} ${HDR}

info:
	@echo '${NAME}:  State assignment for PLA-based finite state machines'

print:: ${DOC} ${MAN}
	${TBL} < ${MAN} | ${TROFF} -P${PRINTER} ${MACROS}

dist: ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN}
	rdist ${RDFLAGS} ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN} ${MISC} ${DISTHOST}:${DISTDEST}

test-dist: ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN}
	rdist ${RDFLAGS} -hv ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN} ${MISC} ${DISTHOST}:${DISTDEST}


depend: ${SRC} ${DRVRSRC} ${HDR}
	@rm -f mktemp
	@sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile > mktemp
	@echo '#--DO NOT CHANGE ANYTHING AFTER THIS LINE' >> mktemp
	@${OCTTOOLS}/bin/cc-M ${INCLUDE} ${SRC} ${DRVRSRC} | sed 's|${OCTTOOLS}|$${OCTTOOLS}|g' >>mktemp
	@mv mktemp Makefile

strip-depend:
	@rm -f mktemp
	@sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile > mktemp
	@mv mktemp Makefile

# does not work with 'pat2tap' creation of devnames.h
#${SRC} ${DRVRSRC} ${HDR}:
#	co $@

#--EXTRA TARGETS
test::
	@${CADBIN}/nova < test.kiss2 | grep -v "^.model" | grep -v "#" | cmp -s - test.out

#--DO NOT CHANGE ANYTHING AFTER THIS LINE
alloc.o: alloc.c ${OCTTOOLS}/include/port.h
alloc.o:  alloc.c nova.h
anneal_code.o: anneal_code.c
anneal_code.o:  ${OCTTOOLS}/include/port.h
anneal_code.o:  anneal_code.c espresso.h nova.h
auxil.o: auxil.c ${OCTTOOLS}/include/port.h
auxil.o:  auxil.c nova.h
coloring.o: coloring.c ${OCTTOOLS}/include/port.h
coloring.o:  coloring.c nova.h
comb_objects.o: comb_objects.c
comb_objects.o:  ${OCTTOOLS}/include/port.h
comb_objects.o:  comb_objects.c nova.h
exact_backtrack.o: exact_backtrack.c
exact_backtrack.o:  ${OCTTOOLS}/include/port.h
exact_backtrack.o:  exact_backtrack.c nova.h
exact_code.o: exact_code.c
exact_code.o:  ${OCTTOOLS}/include/port.h
exact_code.o:  exact_code.c nova.h
exact_graph.o: exact_graph.c
exact_graph.o:  ${OCTTOOLS}/include/port.h
exact_graph.o:  exact_graph.c nova.h
exact_lbound.o: exact_lbound.c
exact_lbound.o:  ${OCTTOOLS}/include/port.h
exact_lbound.o:  exact_lbound.c nova.h
exact_mini.o: exact_mini.c
exact_mini.o:  ${OCTTOOLS}/include/port.h
exact_mini.o:  exact_mini.c nova.h
exact_output.o: exact_output.c
exact_output.o:  ${OCTTOOLS}/include/port.h
exact_output.o:  exact_output.c nova.h
get_constr.o: get_constr.c
get_constr.o:  ${OCTTOOLS}/include/port.h
get_constr.o:  get_constr.c nova.h
ihybrid_code.o: ihybrid_code.c
ihybrid_code.o:  ${OCTTOOLS}/include/port.h
ihybrid_code.o:  ihybrid_code.c nova.h
input_fsm.o: input_fsm.c
input_fsm.o:  ${OCTTOOLS}/include/port.h
input_fsm.o:  input_fsm.c nova.h
iohybrid_code.o: iohybrid_code.c
iohybrid_code.o:  ${OCTTOOLS}/include/port.h
iohybrid_code.o:  iohybrid_code.c nova.h
iovariant_code.o: iovariant_code.c
iovariant_code.o:  ${OCTTOOLS}/include/port.h
iovariant_code.o:  iovariant_code.c nova.h
log_approx.o: log_approx.c
log_approx.o:  ${OCTTOOLS}/include/port.h
log_approx.o:  log_approx.c nova.h
log_code.o: log_code.c ${OCTTOOLS}/include/port.h
log_code.o:  log_code.c nova.h
log_mini.o: log_mini.c ${OCTTOOLS}/include/port.h
log_mini.o:  log_mini.c nova.h
log_output.o: log_output.c
log_output.o:  ${OCTTOOLS}/include/port.h
log_output.o:  log_output.c nova.h
log_precode.o: log_precode.c
log_precode.o:  ${OCTTOOLS}/include/port.h
log_precode.o:  log_precode.c nova.h
log_sel.o: log_sel.c ${OCTTOOLS}/include/port.h
log_sel.o:  log_sel.c nova.h
lower_bound.o: lower_bound.c
lower_bound.o:  ${OCTTOOLS}/include/port.h
lower_bound.o:  lower_bound.c nova.h
nova.o: nova.c ${OCTTOOLS}/include/port.h decls.h
nova.o:  nova.c nova.h
nova_summ.o: nova_summ.c
nova_summ.o:  ${OCTTOOLS}/include/port.h nova.h
nova_summ.o:  nova_summ.c
options.o: options.c ${OCTTOOLS}/include/port.h
options.o:  nova.h options.c
out_encoder.o: out_encoder.c
out_encoder.o:  ${OCTTOOLS}/include/port.h nova.h
out_encoder.o:  out_encoder.c out_encoder.h
out_eval.o: out_eval.c ${OCTTOOLS}/include/port.h
out_eval.o:  nova.h out_eval.c
show.o: show.c ${OCTTOOLS}/include/port.h nova.h
show.o:  show.c
symbolic_loop.o: symbolic_loop.c
symbolic_loop.o:  ${OCTTOOLS}/include/port.h
symbolic_loop.o:  nova.h symbolic_loop.c
user_codes.o: user_codes.c
user_codes.o:  ${OCTTOOLS}/include/port.h nova.h
user_codes.o:  user_codes.c
