#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/doc/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.2 $
# * $Date: 1992/05/06 19:03:52 $
# *
# */
default:
	@echo usage: make [docs] [print] [blif.dvi] [print-blif] [blif.tty]

docs:
	ln -s ../array/array.doc
	ln -s ../astg/astg.doc
	ln -s ../atpg/atpg.doc
	ln -s ../avl/avl.doc
	ln -s ../bdd_ucb/bdd.doc
	ln -s ../clock/clock.doc
	ln -s ../command/command.doc
	ln -s ../decomp/decomp.doc
	ln -s ../delay/delay.doc
	ln -s ../enc/enc.doc
	ln -s ../error/error.doc
	ln -s ../extract/extract.doc
	ln -s ../factor/factor.doc
	ln -s ../gcd/gcd.doc
	ln -s ../genlib/genlib.doc
	ln -s ../graph/graph.doc
	ln -s ../graph/graph_static.doc
	ln -s ../graphics/graphics.doc
	ln -s ../io/io.doc
	ln -s ../latch/latch.doc
	ln -s ../list/list.doc
	ln -s ../map/library.doc
	ln -s ../map/map.doc
	ln -s ../maxflow/maxflow.doc
	ln -s ../mincov/mincov.doc
	ln -s ../minimize/minimize.doc
	ln -s ../network/network.doc
	ln -s ../node/node.doc
	ln -s ../node/nodeindex.doc
	ln -s ../ntbdd/ntbdd.doc
	ln -s ../octio/octio.doc
	ln -s ../order/order.doc
	ln -s ../phase/phase.doc
	ln -s ../pld/pld.doc
	ln -s ../power/power.doc
	ln -s ../resub/resub.doc
	ln -s ../retime/retime.doc
	ln -s ../simplify/simplify.doc
	ln -s ../sparse/sparse.doc
	ln -s ../speed/speed.doc
	ln -s ../st/st.doc
	ln -s ../stg/stg.doc
	ln -s ../timing/timing.doc
	ln -s ../util/util.doc
	ln -s ../var_set/var_set.doc

print:
	enscript -Plps40 *.doc

blif.tty: blif.dvi
	dvitty blif.dvi > blif.tty

blif.dvi: blif.tex
	-latex blif

print-blif: blif.dvi
	lwtex lps40 blif.dvi
