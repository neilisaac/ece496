# -----------------------------------------------------------------------------
# Makefile for XSIS, graphical interface to SIS.
#
# Requires X11R4 Athena widget set and UCB sis library.
#
# Variables:
#
#   $(SIS)  = path to lib/libsis.a, include/sis.h, ...
#   $(X11)  = path to lib/libX11.a, include/X11/X11.h, ...
#   $(DEST) = path $(DEST)/bin, $(DEST)/man for installation.
#
# Targets:
#
#   default:	build xsis program.
#   install:	build xsis, install it and its manpage in $(DEST).
#   clean:	delete everything that can be rebuilt.
#   depend:	run the makedepend program to add dependencies.
#   headers:	add sis RCS headers
#
# -----------------------------------------------------------------------------

SIS	= ../../../$(MACHINE)
X11	= /usr/sww/X11
DEST	= ../../../$(MACHINE)

TARGET	= xsis

SRC	= NetPlot.c \
	  xcmd.c xhelp.c xblif.c xastg.c xsis.c \
	  xutil.c main.c

HDR	= NetPlot.h NetPlotP.h \
	  xsis.h ghost.px help50.px sis50.px blif50.px

OBJ	= $(SRC:.c=.o)

MISC	= Makefile xsis.1

INCLUDE	= -I$(X11)/include -I$(SIS)/include

LIBS	= $(SIS)/lib/libsis.a
LIBS2	= -L$(X11)/lib -lXaw -lXmu -lXt -lXext -lX11 -lm

# ---------------------------------------------------------------------------

CC	= cc
CFLAGS	= -O $(INCLUDE)
LDFLAGS	=

$(TARGET): $(OBJ) $(LIBS)
	$(CC) -o $(TARGET) $(LDFLAGS) $(OBJ) $(LIBS) $(LIBS2)

clean:
	rm -f $(TARGET) $(OBJ) core Makefile.bak xsis.ps

$(DEST):
	mkdir $(DEST)
	chmod go+rx $(DEST)

xsis.ps:
	psroff -tbl -t -man xsis.1 > xsis.ps

install: $(TARGET) $(DEST)
	mv $(TARGET) $(DEST)/bin
	cd $(DEST)/man/man1;\
	rm -f $(TARGET).1;\
	ln -s ../../src/xsis/$(TARGET).1 .

headers:
#	$(SIS)/../common/rcs_file *.px
	$(SIS)/../common/rcs_makef Makefile
	$(SIS)/../common/rcs_manf xsis.1

depend: $(INCDIR)
	makedepend -f Makefile -DMAKE_DEPEND $(IFLAGS) $(SRC)

MSG	= Check-in message
ci:
	ci -u -q -m"$(MSG)" $(MISC) $(HDR) $(SRC)

# DO NOT DELETE THIS LINE -- make depend depends on it.

NetPlot.o: NetPlotP.h NetPlot.h
xcmd.o: xsis.h
xhelp.o: xsis.h NetPlot.h help50.px
xblif.o: xsis.h NetPlot.h blif50.px
xastg.o: xsis.h NetPlot.h
xsis.o: xsis.h NetPlot.h ghost.px sis50.px
main.o: xsis.h
