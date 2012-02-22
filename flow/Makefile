P=test

.PHONY: clean flash verilog view

.SECONDARY:

all: $(P).done

clean:
	rm -f *.echo *.pyc *.pyo *.log *.blif *.out *.net *.done abc.cmd gc.txt $(P).bit $(P).uart-tb.v

$(P).odin.blif: $(P).v
	bin/odin_ii -V $< -o $(P).odin.blif 2> $(P).odin.log > $(P).odin.log

$(P).abc.blif: $(P).odin.blif
	printf "read $<\nif -K 6\nsweep\nwrite_hie $< $@" > abc.cmd
	bin/abc-vtr -f abc.cmd  > $(P).abc.log

$(P).awk.blif: $(P).abc.blif
	cat $< | awk '{ if ($$1 == ".latch"){ print $$1, $$2, $$3, "re", "top^clk", $$4 } else { print $$0 } }' > $@

$(P).net: $(P).awk.blif
	bin/t-vpack $< $@ -inputs_per_cluster 16 -cluster_size 4 -lut_size 6 > $(P).vpack.log

$(P).place.out: $(P).net
	bin/vpr $< -nodisp k6-n4.xml $(P).place.out $(P).route.out -fix_pins $(P).pads -route_chan_width 4 > $(P).vpr.log

view: $(P).net
	bin/vpr $< k6-n4.xml $(P).place.out $(P).route.out -fix_pins $(P).pads -route_chan_width 4 > $(P).vpr.log

$(P).done: $(P).place.out
	./fpga.py $(P).place.out $(P).route.out $(P).net $(P).abc.blif > $(P).bit
	touch $@

verilog: $(P).done
	./program_bitstream.py --file $(P).bit --dry --sim $(P).uart-tb.v

flash: $(P).done
	./program_bitstream.py --file $(P).bit

