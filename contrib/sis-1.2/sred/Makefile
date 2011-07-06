#
#  Octtools Makefile
#
#  sred - heuristic state minimization program
#
#  Makefile created on Thu Jul 1 04:23:59 PDT 1993 by luciano (using 'create-octtools-makefile')
#
#  Copyright (c) 1988, 1989, 1990, Regents of the University of California
#
#  For a description of the 'targets and variables': say "make help"
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

OCTTOOLS	= /projects/octtools/octtools/$(MACHINE)
# SIS	= /projects/classes/sis/$(MACHINE)
SIS	= /usr/eesww/sis
UTILS	= ${OCTTOOLS}/utils
XINCLOC = -I/usr/local/X11R4/include
XLIBLOC = -L/usr/local/X11R4/lib

LINTCREATEFLAG = -C
LINTEXTRAS =
LDEXTRAS =
DBGFLAG =
OPTFLAG = -O

# an alternative if you want links in the installation locations
# back to the source directories would be:
#   CP = sh -c 'ln -s `pwd`/$$0 $$1'
CP = cp

BUILD = ${OCTTOOLS}/bin/create-octtools-makefile

# cute hack for the sequent
#   setenv PARALLEL 8; make P="&" install
P = 

NAME	= sred

# packages required for this package/tool
REQUIRE	= 

# tools required for this tool
TOOLREQUIRE = 

SRC	= main.c action.c gram.c lex.c label.c incompat.c connected.c comp.c coloring.c qsort.c qspivot.c qspart.c mxcomptbl.c closure.c generate.c exist.c strbar.c strcom.c solution.c choose.c clincop.c prime.c primeones.c clinclus.c chinclus.c chiusura.c clinchain.c existdf.c newprime.c boolcmp.c ibincompa.c obincompa.c iobincomp.c reduced.c newnstate.c newoutput.c procargs.c makeout.c misc.c esp_color.c
LSRC	= main.c action.c gram.c lex.c label.c incompat.c connected.c comp.c coloring.c qsort.c qspivot.c qspart.c mxcomptbl.c closure.c generate.c exist.c strbar.c strcom.c solution.c choose.c clincop.c prime.c primeones.c clinclus.c chinclus.c chiusura.c clinchain.c existdf.c newprime.c boolcmp.c ibincompa.c obincompa.c iobincomp.c reduced.c newnstate.c newoutput.c procargs.c makeout.c misc.c esp_color.c
OBJ	= main.o action.o gram.o lex.o label.o incompat.o connected.o comp.o coloring.o qsort.o qspivot.o qspart.o mxcomptbl.o closure.o generate.o exist.o strbar.o strcom.o solution.o choose.o clincop.o prime.o primeones.o clinclus.o chinclus.o chiusura.o clinchain.o existdf.o newprime.o boolcmp.o ibincompa.o obincompa.o iobincomp.o reduced.o newnstate.o newoutput.o procargs.o makeout.o misc.o esp_color.o
HDR	= reductio.h

CADBIN	= ${OCTTOOLS}/bin

TOOLINSTALL= ${CADBIN}/${TARGET} ${OCTTOOLS}/man/man1/${MAN}
INSTALL	= ${PKGINSTALL} ${TOOLINSTALL} 

DISTDEST= ${OCTTOOLS}/src/${NAME}
DISTHOST= BOGUS-HOST
MISC	= Makefile Makefile.template 

LIBS	= $(SIS)/lib/libsis.a
LINTLIBS= 

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
		"OCTTOOLS=${OCTTOOLS}" \
		"CC=${CC}" \
		"OPTFLAG=${OPTFLAG}" \
		"DBGFLAG=${DBGFLAG}" \
		"RDFLAGS=${RDFLAGS}" \
		"CP=${CP}" \
		"LINTCREATEFLAG=${LINTCREATEFLAG}" \
		"LDEXTRAS=${LDEXTRAS}" \
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

INCLUDE	= ${XINCLOC}  -I${SIS}/include
CFLAGS	= ${OPTFLAG} ${DBGFLAG} ${INCLUDE} 
YFLAGS = -d
VERSION	= "-DCUR_DATE=\"`date | awk '{print $$2, $$3, $$6}'`\"" \
	  "-DCUR_TIME=\"`date | awk '{print $$4}'`\""
LINTFLAGS= ${INCLUDE} ${LINTEXTRAS}
LDFLAGS	= ${XLIBLOC}  -lm ${LDEXTRAS}
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
	@rm -f ${OBJ} ${DRVROBJ} ${TARGET} ${TARGETG} ${TARGETPG} ${DRIVER} 
	@rm -f tags TAGS ${LIB} ${LIBG} ${LIBPG} ${LINTLIB} lint 
	@rm -f make.out mktemp core .p .pg *~ __________ELEL_

require:
	@echo ${REQUIRE}

help:
	@more ${OCTTOOLS}/lib/utils/Makefile.help

toolrequire:
	@echo ${TOOLREQUIRE}

test::
	@test -f ${CADBIN}/${TARGET}

tags: ${LSRC} ${DRVRSRC} ${HDR}
	ctags ${LSRC} ${DRVRSRC} ${HDR}

TAGS: ${LSRC} ${DRVRSRC} ${HDR}
	etags ${LSRC} ${DRVRSRC} ${HDR}

info:
	@echo '${NAME}:  heuristic state minimization program'

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

#--DO NOT CHANGE ANYTHING AFTER THIS LINE
