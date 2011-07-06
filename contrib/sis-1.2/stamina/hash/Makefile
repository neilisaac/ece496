#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/hash/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.3 $
# * $Date: 1994/07/15 22:58:45 $
# *
# */
#
#   This makefile uses built-in dependencies. (Compare with Make.back)
#
#   This is a Makefile for hash table.
#
#
#   Makefile for directory /duke/research/xuejun/encoding/hash
#
#.DEFAULT:
#	co $@

OUTPUT = hash
 
CSRC	= hash_drive.c hash_initial.c install.c  lookup.c hash.c hash_dump.c

COBJS   =  hash_drive.o hash_initial.o install.o lookup.o hash.o hash_dump.o

LIBS    = -lm -lc

INCLUDE = $(SIS)/util
CFLAGS	= -I$(INCLUDE)

#--------------------------------------------------------------------------
hash: $(COBJS)
	$(CC) $(COBJS) $(LIBS) -o hash

$(COBJS): hash.h 		# since $(COBJS) depend on hash.h


install: libhash.a llib-lhash.ln # install the two libraries.

print: *.h *.c 			# this target seems not working
	lpr $? 
	touch print
	
libhash.a: $(COBJS) 		# making a library.
	ar rv libhash.a $(COBJS)
	ranlib libhash.a	# this is required by Berkeley's Unix system.


llib-lhash.ln: $(CSRC) hash.h   # making a lint library.
	lint $(INCLUDE) -Chash $(CSRC)

lint:				# run lint.
	lint -bux $(INCLUDE) $(CSRC)

#---------------------------------------------------------------------------
hash_drive.o: hash_drive.c hash.h
hash_initial.o: hash_initial.c hash.h
install.o: install.c hash.h
lookup.o: lookup.c hash.h
hash.o: hash.c hash.h
hash_dump.o: hash_dump.c hash.h


clean:
	rm -f a.out *.a *.ln core $(COBJS) 
