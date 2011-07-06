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
#  espresso - two-level minimization
#
#  Makefile created on Tue Jan 16 15:52:31 PST 1990 by octtools (using 'create-octtools-makefile')
#
#  Copyright (c) 1988, 1989, 1990, Regents of the University of California
#
#
# Description of the 'targets':
#
#  all:			create the tags file, run lint, build the tool/package
#  prog:		build the tool
#  install:		build the tool/package and install
#  uninstall:		remove the files that would be installed with 'install'
#  debug:		build and install the debug versions of the package
#				(for tools, build the debug versions and leave 
#				in the source directories)
#  header:		install the exported header files for the package
#  lint:		run lint
#  clean:		remove the binary, object files, and temporary files
#  require:		echo the packages directly used by the tool/package
#  toolrequire:		echo a list of tools used in the running of the tool
#  test:		run a simple test on the tool/package
#  tags:		build the 'tags' file (for 'vi')
#  TAGS:		build the 'TAGS' file (for 'emacs')
#  info:		echo a one-line description of the tool/package
#  print:		print out the man page or doc file for the tool/package
#  dist:		dist the tool/package
#  test-dist:		tell what would be disted in 'make dist' were run
#  depend:		generate the dependency information
#  strip-depend:	remove the dependency information
#
#
# Description of the 'variables':
#
#  BUILD:		name of the program that builds a 'Makefile' from
#				'Makefile.template'
#  CAD:			location of the CAD tools (for installation)
#  CADROOT:		run-time location of the CAD libraries (can have '~')
#  CC:			name of the C-compiler
#  OPTFLAG:		optimization level (usually nothing, -O, or -O#)
#  DBGFLAG:		debug level (usually nothing, -g, or -pg)
#  CP:			name of the program used for installation
#  LDFLAGS:		flags used for linking (e.g., -lXMenu -lX -lm)
#  LINTCREATEFLAG:	flag used by 'lint' for creating lint libraries
#			(-C for BSD, ULTRIX, SUN; -o for IBM RT/PC, ULTRIX/RISC)
#  P:			either nothing or & - used by the sequent to
#				parallelize compiles
#  PRINTER:		name of the printer
#  SHELL:		shell used by 'make' (should always be the bourne shell)
#  UTILS:		location of the utility programs
#
#
#------------------------------------------------------------------------------

# for HPUX
SHELL	= /bin/sh

MAKE = /bin/make

CAD	= /octtools/release-3.0
CADROOT	= ~octtools
UTILS	= ${CAD}/utils

LINTCREATEFLAG = -C
LINTEXTRAS =
DBGFLAG =
OPTFLAG =

# an alternative if you want links in the installation locations
# back to the source directories would be:
#   CP = sh -c 'ln -s `pwd`/$$0 $$1'
CP = cp

BUILD = ${UTILS}/bin/create-octtools-makefile

# cute hack for the sequent
#   setenv PARALLEL 8; make P="&" install
P = 

NAME	= espresso

# packages required for this package/tool
REQUIRE	= utility

# tools required for this tool
TOOLREQUIRE = 

SRC	= cofactor.c cols.c compl.c contain.c cubestr.c cvrin.c cvrm.c cvrmisc.c cvrout.c dominate.c equiv.c espresso.c essen.c exact.c expand.c gasp.c getopt.c gimpel.c globals.c hack.c indep.c irred.c main.c map.c matrix.c mincov.c opo.c pair.c part.c primes.c reduce.c rows.c set.c setc.c sharp.c sminterf.c solution.c sparse.c unate.c verify.c
LSRC	= cofactor.c cols.c compl.c contain.c cubestr.c cvrin.c cvrm.c cvrmisc.c cvrout.c dominate.c equiv.c espresso.c essen.c exact.c expand.c gasp.c getopt.c gimpel.c globals.c hack.c indep.c irred.c main.c map.c matrix.c mincov.c opo.c pair.c part.c primes.c reduce.c rows.c set.c setc.c sharp.c sminterf.c solution.c sparse.c unate.c verify.c
OBJ	= cofactor.o cols.o compl.o contain.o cubestr.o cvrin.o cvrm.o cvrmisc.o cvrout.o dominate.o equiv.o espresso.o essen.o exact.o expand.o gasp.o getopt.o gimpel.o globals.o hack.o indep.o irred.o main.o map.o matrix.o mincov.o opo.o pair.o part.o primes.o reduce.o rows.o set.o setc.o sharp.o sminterf.o solution.o sparse.o unate.o verify.o
HDR	= espresso.h main.h mincov.h mincov_int.h sparse.h sparse_int.h

CADBIN	= ${CAD}/bin

TOOLINSTALL= ${CADBIN}/${TARGET} ${CAD}/man/man1/${MAN}
INSTALL	= ${PKGINSTALL} ${TOOLINSTALL} ${CAD}/man/man5/espresso.5 ${CAD}/man/man5/pla.5 ${CAD}/lib/espresso

DISTDEST= ${CAD}/src/${NAME}
DISTHOST= BOGUS-HOST
MISC	= Makefile Makefile.template ex examples espresso.5 pla.5

#LIBS	= $(CAD)/lib/libutility$(DBGFLAG).a $(CAD)/lib/libst$(DBGFLAG).a $(CAD)/lib/libmm$(DBGFLAG).a $(CAD)/lib/liberrtrap$(DBGFLAG).a $(CAD)/lib/libuprintf$(DBGFLAG).a $(CAD)/lib/libport$(DBGFLAG).a
LIBS	= $(CAD)/lib/libutility$(DBGFLAG).a
LINTLIBS= $(CAD)/lib/llib-lutility.ln

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
		"UTILS=${UTILS}" \
		"VPATH=${VPATH}"

INCLUDE	=  -I$(CAD)/include
CFLAGS	= ${OPTFLAG} ${DBGFLAG} ${INCLUDE} '-DCADROOT="${CADROOT}"'
VERSION	= "-DCUR_DATE=\"`date | awk '{print $$2, $$3, $$6}'`\"" \
	  "-DCUR_TIME=\"`date | awk '{print $$4}'`\""
LINTFLAGS= ${INCLUDE} '-DCADROOT="${CADROOT}"'${LINTEXTRAS}
LDFLAGS	=  -lm

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

${CAD}/man/man1/${MAN}: ${MAN}
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

toolrequire:
	@echo ${TOOLREQUIRE}

test::
	@test -f ${CADBIN}/${TARGET}

tags: ${LSRC} ${DRVRSRC} ${HDR}
	ctags ${LSRC} ${DRVRSRC} ${HDR}

TAGS: ${LSRC} ${DRVRSRC} ${HDR}
	etags ${LSRC} ${DRVRSRC} ${HDR}

info:
	@echo '${NAME}:  two-level minimization'

print:: ${DOC} ${MAN}
	${TBL} < ${MAN} | ${TROFF} -P${PRINTER} ${MACROS}

dist: ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN}
	rdist -Rich ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN} ${MISC} ${DISTHOST}:${DISTDEST}

test-dist: ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN}
	rdist -Richv ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN} ${MISC} ${DISTHOST}:${DISTDEST}


depend: ${SRC} ${DRVRSRC} ${HDR}
	@rm -f mktemp
	@sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile > mktemp
	@echo '#--DO NOT CHANGE ANYTHING AFTER THIS LINE' >> mktemp
	@${UTILS}/bin/cc-M ${INCLUDE} ${SRC} ${DRVRSRC} | sed 's|${CAD}|$${CAD}|g' >>mktemp
	@mv mktemp Makefile

strip-depend:
	@rm -f mktemp
	@sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile > mktemp
	@mv mktemp Makefile

# does not work with 'pat2tap' creation of devnames.h
#${SRC} ${DRVRSRC} ${HDR}:
#	co $@

#--EXTRA TARGETS
${CAD}/man/man5/espresso.5: espresso.5
	rm -f $@
	tbl < $? > $@

${CAD}/man/man5/pla.5: pla.5
	rm -f $@
	tbl < $? > $@

${CAD}/lib/espresso: ex
	rm -rf $@
	-mkdir $@
	-cp -r $? $@

test::
	(cd examples; make CAD=${CAD} > ../test.out 2>&1)

clean::
	rm -f test.out

clean::
	(cd examples; make clean)


