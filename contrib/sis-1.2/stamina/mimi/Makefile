#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/mimi/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.3 $
# * $Date: 1994/07/15 22:58:50 $
# *
# */
# SCCSID %W%
# State Minimization of incompletely specified Finite State Machine 
#

SRC=$(CSRC) $(HSRC)

CSRC=main.c read_fsm.c install_state.c merge.c stack.c max.c\
 prime.c class.c bcover.c map.c conf.c disjoint.c misc.c iso.c

HSRC=max.h stack.h merge.h

OBJ=main.o read_fsm.o install_state.o merge.o stack.o max.o\
 prime.o class.o bcover.o map.o conf.o disjoint.o misc.o iso.o

LIBDIR=../lib/$(MACHINE)
LIB=$(LIBDIR)/libhash.a 
SISLIBS = $(SIS)/mincov/libmincov.a $(SIS)/sparse/libsparse.a \
	  $(SIS)/util/libutil.a

INCLUDE=-I../hash -I$(SIS)/mincov -I$(SIS)/sparse -I$(SIS)/util

CFLAG= -c -O

install: stamina
	cp stamina $(INSDIR)

stamina: $(OBJ) $(LIB) $(SISLIBS)
	$(CC) -o stamina $(OBJ) $(LIB) $(SISLIBS)

.c.o:
	$(CC) $(CFLAG) $(INCLUDE) $*.c

main.o:  struct.h user.h
install_state.o:
stack.o: struct.h user.h
max.o: max.h user.h
prime.o: max.h user.h
class.o: max.h user.h
bcover.o: struct.h user.h
map.o: struct.h user.h
conf.o:
read_fsm.o: struct.h user.h
install_state.o: struct.h user.h
merge.o: user.h
disjoint.o: ../hash/hash.h user.h

clean:
	rm -f *.o stamina

lint:
	lint $(INCLUDE) $(CSRC) > lint.err

sccsedit:
	sccs get -e $(SRC)

sccsprt:
	sccs get $(SRC)

sccsdelta:
	sccs delta $(SRC)
