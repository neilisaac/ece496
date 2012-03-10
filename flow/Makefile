# usage to compile mydir/mydir.v: make D=mydir flash

D?=adder
P?=$(D)/$(D)

BIN?=bin
SCRIPTS?=scripts
ARCH?=vpr5-k6-n4.xml
TRACKS?=8
ROWS=4
COLS=4

ODIN=$(BIN)/odin_ii
ABC=$(BIN)/abc-vtr
VPACK=$(BIN)/t-vpack
VPR=$(BIN)/vpr5

.PHONY: clean flash verilog view

.SECONDARY:

all: $(P).done

clean:
	rm -f gc.txt *.echo $(D)/abc.cmd $(P).*.log $(P).*.blif $(P).*.out $(P).net $(P).done $(P).bit $(P).uart-tb.v

$(P).odin.blif: $(P).v
	$(ODIN) -V $< -o $(P).odin.blif 2> $(P).odin.log > $(P).odin.log

$(P).abc.blif: $(P).odin.blif
	printf "read $<\nif -K 6\nsweep\nwrite_hie $< $@" > $(D)/abc.cmd
	$(ABC) -f $(D)/abc.cmd  > $(P).abc.log

$(P).awk.blif: $(P).abc.blif
	cat $< | awk '{ if ($$1 == ".latch"){ print $$1, $$2, $$3, "re", "top^clk", $$4 } else { print $$0 } }' > $@

$(P).net: $(P).awk.blif
	$(VPACK) $< $@ -inputs_per_cluster 16 -cluster_size 4 -lut_size 6 > $(P).vpack.log

$(P).place.out: $(P).pads $(P).net
	$(VPR) $(P).net $(ARCH) $(P).place.out $(P).route.out -nodisp -fix_pins $(P).pads -route_chan_width $(TRACKS) > $(P).vpr.log

view: $(P).awk.blif
	$(VPR) $(P).net $(ARCH) $(P).place.out $(P).route.out -fix_pins $(P).pads -route_chan_width $(TRACKS) > $(P).vpr.log

$(P).done: $(P).place.out
	$(SCRIPTS)/fpga.py $(P).place.out $(P).route.out $(P).net $(P).abc.blif > $(P).bit
	touch $@

verilog: $(P).done
	$(SCRIPTS)/program_bitstream.py --file $(P).bit --dry --sim $(P).uart-tb.v

flash: $(P).done
	$(SCRIPTS)/program_bitstream.py --file $(P).bit

