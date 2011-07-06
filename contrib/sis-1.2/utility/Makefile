#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/utility/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.3 $
# * $Date: 1994/07/15 22:55:23 $
# *
# */
#
#  Octtools Makefile
#
#  utility - Provides commonly used functions and macros
#
#  Makefile created on Mon Apr 30 11:48:29 PDT 1990 by octtools (using 'create-octtools-makefile')
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
AR = ar
RANLIB = ranlib
CPLUSPLUS = g++

OCTTOOLS=/projects/octtools/octtools/${MACHINE}
CADROOT	= $$OCTTOOLS
UTILS	= ${OCTTOOLS}/utils

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

NAME	= utility

# packages required for this package/tool
REQUIRE	= st mm port

# tools required for this tool
TOOLREQUIRE = 

SRC	= cpu_time.c csystem.c pathsearch.c pipefork.c prtime.c strsav.c texpand.c tmpfile.c
LSRC	= cpu_time.c csystem.c pathsearch.c pipefork.c prtime.c strsav.c texpand.c tmpfile.c
OBJ	= cpu_time.o csystem.o pathsearch.o pipefork.o prtime.o strsav.o texpand.o tmpfile.o
HDR	= utility.h
EXPHDR	= ${NAME}.h

DRVRSRC	= uttest.c
DRVROBJ	= uttest.o
DRIVER	= $(NAME)-test

CADBIN	= ${OCTTOOLS}/bin

PKGINSTALL= ${OCTTOOLS}/lib/${LIB} ${OCTTOOLS}/include/${EXPHDR} ${OCTTOOLS}/doc/${DOC}
LINTINSTALL = ${OCTTOOLS}/lib/${LINTLIB}
INSTALL	= ${PKGINSTALL} ${TOOLINSTALL} 

DISTDEST= ${OCTTOOLS}/src/${NAME}
DISTHOST= BOGUS-HOST
MISC	= Makefile Makefile.template 

LIBS	= $(OCTTOOLS)/lib/libst$(DBGFLAG).a $(OCTTOOLS)/lib/libmm$(DBGFLAG).a $(OCTTOOLS)/lib/liberrtrap$(DBGFLAG).a $(OCTTOOLS)/lib/libuprintf$(DBGFLAG).a $(OCTTOOLS)/lib/libport$(DBGFLAG).a
LINTLIBS= $(OCTTOOLS)/lib/llib-lst.ln $(OCTTOOLS)/lib/llib-lmm.ln $(OCTTOOLS)/lib/llib-lport.ln

LIB	= lib${NAME}.a
LIBPG	= lib${NAME}-pg.a
LIBG	= lib${NAME}-g.a
LINTLIB	= llib-l${NAME}.ln
DOC	= ${NAME}.doc

PRINTER	= lps40
MACROS	= -man.4.3
PRINT	= lpr
TROFF	= ptroff
TBL	= tbl

MAKEVARS =	\
		"CAD=${OCTTOOLS}" \
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
		"AR=${AR}" \
		"RANLIB=${RANLIB}" \
		"CPLUSPLUS=${CPLUSPLUS}" \
		"VPATH=${VPATH}"

INCLUDE	= -I$(CAD)/include
CFLAGS	= ${OPTFLAG} ${DBGFLAG} ${INCLUDE} '-DCADROOT="${CADROOT}"'
VERSION	= "-DCUR_DATE=\"`date | awk '{print $$2, $$3, $$6}'`\"" \
	  "-DCUR_TIME=\"`date | awk '{print $$4}'`\""
LINTFLAGS= ${INCLUDE} '-DCADROOT="${CADROOT}"' ${LINTEXTRAS}
LINTLIBFLAGS= ${INCLUDE} '-DCADROOT="${CADROOT}"' ${LINTEXTRAS}
LDFLAGS	= -lm

#-----------------------------------------------------------------------


all: tags lint ${LIB} ${LINTLIB}

build: Makefile.template
	${BUILD} Makefile.template

install: ${INSTALL}
install.lint: ${LINTINSTALL}

uninstall:
	rm -rf ${INSTALL} ${LINTINSTALL} ${OCTTOOLS}/lib/${LIBG} ${OCTTOOLS}/lib/${LIBPG}

version.o: version.c
	${CC} ${CFLAGS} ${VERSION} -c version.c
	-touch -f version.c

debug: debug-g debug-pg

debug-g: ${OCTTOOLS}/lib/${LIBG}

debug-pg: ${OCTTOOLS}/lib/${LIBPG}



${DRIVER}:${P} ${DRVROBJ} ${LIB} ${LIBS}
	${CC} ${OPTFLAG} ${DBGFLAG} -o ${DRIVER} ${DRVROBJ} ${LIB} ${LIBS} ${LDFLAGS}



${LIB}:${P} ${OBJ}
	${AR} r $@ $?
	${RANLIB} $@

${LINTLIB}: ${LSRC} ${HDR}
	lint ${LINTLIBFLAGS} ${LINTCREATEFLAG}${NAME} -n ${LSRC}

${LIBPG}: ${SRC} ${HDR}
	rm -f ${OBJ}
	-${AR} xo $@
	$(MAKE) $(MFLAGS) DBGFLAG=-pg $(MAKEVARS) .pg
	-${AR} xo ${LIB}

.pg :${P} ${OBJ}
	${AR} r ${LIBPG} $?
	${RANLIB} ${LIBPG}
	touch .pg

${LIBG}: ${SRC} ${HDR}
	rm -f ${OBJ}
	-${AR} xo $@
	$(MAKE) $(MFLAGS) DBGFLAG=-g $(MAKEVARS) .g
	-${AR} xo ${LIB}

.g :${P} ${OBJ}
	${AR} r ${LIBG} $?
	${RANLIB} ${LIBG}
	touch .g

${OCTTOOLS}/lib/${LIB}: ${LIB}
	rm -f $@
	${CP} $? $@
	${RANLIB} $@

header:: ${OCTTOOLS}/include/${EXPHDR}

${OCTTOOLS}/include/${EXPHDR}: ${EXPHDR}
	rm -f $@
	${CP} $? $@

${OCTTOOLS}/lib/${LINTLIB}: ${LINTLIB}
	rm -f $@
	${CP} $? $@

${OCTTOOLS}/doc/${DOC}: ${DOC}
	rm -f $@
	${CP} $? $@

${OCTTOOLS}/lib/${LIBG}: ${LIBG}
	rm -f $@
	${CP} $? $@
	${RANLIB} $@

${OCTTOOLS}/lib/${LIBPG}: ${LIBPG}
	rm -f $@
	${CP} $? $@
	${RANLIB} $@


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
	@test -f ${OCTTOOLS}/lib/${LIB}

tags: ${LSRC} ${DRVRSRC} ${HDR}
	ctags ${LSRC} ${DRVRSRC} ${HDR}

TAGS: ${LSRC} ${DRVRSRC} ${HDR}
	etags ${LSRC} ${DRVRSRC} ${HDR}

info:
	@echo '${NAME}:  Provides commonly used functions and macros'

print:: ${DOC} ${MAN}
	${PRINT} -P${PRINTER} ${DOC}

dist: ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN}
	rdist -Rich ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN} ${MISC} ${DISTHOST}:${DISTDEST}

test-dist: ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN}
	rdist -Rickhv ${SRC} ${DRVRSRC} ${HDR} ${DOC} ${MAN} ${MISC} ${DISTHOST}:${DISTDEST}


depend: ${SRC} ${DRVRSRC} ${HDR}
	@rm -f mktemp
	@sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile > mktemp
	@echo '#--DO NOT CHANGE ANYTHING AFTER THIS LINE' >> mktemp
	@${UTILS}/bin/cc-M ${INCLUDE} ${SRC} ${DRVRSRC} | sed 's|${OCTTOOLS}|$${OCTTOOLS}|g' >>mktemp
	@mv mktemp Makefile

strip-depend:
	@rm -f mktemp
	@sed '/^#--DO NOT CHANGE ANYTHING AFTER THIS LINE/,$$d' Makefile > mktemp
	@mv mktemp Makefile

# does not work with 'pat2tap' creation of devnames.h
#${SRC} ${DRVRSRC} ${HDR}:
#	co $@

#--EXTRA TARGETS
test:: ${DRIVER}
	@csh -c 'setenv OCTTOOLS-TRANSLATIONS "first-translation:/first,second-translation:/second,third-translation:/third"; ${DRIVER}'


