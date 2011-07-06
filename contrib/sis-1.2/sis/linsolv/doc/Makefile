# Makefile for Sparse documentation
#

PRINTER = -Plps20a
# PRINTER = -Plps40

default		: usersguide
all		: usersguide install advert

usersguide	: spDoc.ms
	tbl spDoc.ms | eqn | > spDoc.1

install:
advert: advert.ms
	tbl advert.ms > advert.1
	
print:
	ditroff -ms $(PRINTER) spDoc.1
	ditroff -ms $(PRINTER) install.ms
	ditroff -ms $(PRINTER) advert.1

all-lpr		: usersguide.lpr install.lpr

usersguide.lpr	: spDoc
spDoc		: spDoc.ms
	tbl spDoc.ms | neqn | nroff -ms | colcrt - > spDoc

install.lpr	: install.ms
	nroff -ms install.ms | colcrt - > install.lpr

clean :
	rm -rf *.1

