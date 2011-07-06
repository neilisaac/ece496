CAD= /net/shambhala/users/octtools-3.0

BINARY = ${CAD}/bin/espresso
TARGETS = dc1.out mlp4.out Z5xp1.out bca.out cps.out opa.out ti.out tial.out

all: ${TARGETS}

dc1.out: dc1
	rm -f $@
	time $(BINARY) -t dc1 > $@

mlp4.out: mlp4
	rm -f $@
	time $(BINARY) -t mlp4 > $@

Z5xp1.out: Z5xp1
	rm -f $@
	time $(BINARY) -t Z5xp1 >Z5xp1.out

bca.out: bca
	rm -f $@
	time $(BINARY) -t bca > $@

cps.out: cps
	rm -f $@
	time $(BINARY) -t cps > $@

opa.out: opa
	rm -f $@
	time $(BINARY) -t opa > $@

ti.out: ti
	rm -f $@
	time $(BINARY) -t ti > $@

tial.out: tial
	rm -f $@
	time $(BINARY) -t tial > $@

clean:
	rm -f $(TARGETS) Make.out

