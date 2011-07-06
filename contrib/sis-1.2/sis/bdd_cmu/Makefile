# This Makefile is used to build the libraries of all the package in bdd_cmu

SIS = $(PWD)/..
CURRENT = $(SIS)/bdd_cmu

P = bdd
DIRS = mem bdd_cmu bdd_port

LIBS =  bdd_cmu/libbdd_cmu.a \
	bdd_port/libbdd_port.a \
	mem/libmem.a

lib$(P).a:
	make $(MFLAGS) CURRENT=$(CURRENT) SIS=$(SIS) libs
	ar cr libbdd.a $(LIBS)
	ranlib lib$(P).a

libs: 
	@for dir in $(DIRS); do                   \
		(cd $$dir;                        \
		echo Making $$dir...;             \
		$(MAKE) $(MFLAGS) CURRENT=$(CURRENT) SIS=$(SIS) lib;       \
		echo Done making $$dir...);       \
	done

unpack: lib$(P).a
	@for i in $(DIRS); do			  \
	    ln -s $(SIS)/$(P)/$$i/*.o $(SIS)/unpack;  \
	done

clean: 
	@for dir in $(DIRS); do                   \
		(cd $$dir;                        \
		echo Cleaning $$dir...;             \
		$(MAKE) $(MFLAGS) CURRENT=$(CURRENT) SIS=$(SIS) clean); \
	done
	rm -rf lib$(P).a

strip_depend:

