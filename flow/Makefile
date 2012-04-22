# usage to compile mydir/mydir.v: make D=mydir flash

# flow directory
FLOW?=.

# directory for project files
DIR?=adder

# prefix for file names
P?=$(DIR)/$(DIR)

# configuration variables
TRACKS?=4
ROWS?=2
COLS?=2
PADVERSION?=clk

# file path configuration
BIN?=$(FLOW)/bin
SCRIPTS?=$(FLOW)/scripts
ARCH?=$(FLOW)/vpr6-k6-n4.template.xml
PADS?=$(FLOW)/pads/pads-$(COLS)x$(ROWS)-$(PADVERSION).txt

# binary paths
ODIN=$(BIN)/odin_ii
ABC=$(BIN)/abc-vtr
VPR=$(BIN)/vpr6

.PHONY: clean flash verilog view

.SECONDARY:

all: $(P).done

clean:
	rm -f gc.txt *.echo $(DIR)/abc.cmd $(P).*.log $(P).*.blif $(P).*.out $(P).*.view $(P).net $(P).done $(P).bit $(P).uart-tb.v $(P).arch.xml

$(P).odin.blif: $(P).v
	$(ODIN) -V $< -o $(P).odin.blif 2> $(P).odin.log > $(P).odin.log

$(P).abc.blif: $(P).odin.blif
	printf "read $<\nif -K 6\nsweep\nwrite_hie $< $@" > $(DIR)/abc.cmd
	$(ABC) -f $(DIR)/abc.cmd  > $(P).abc.log

$(P).awk.blif: $(P).abc.blif
	cat $< | awk '{ if ($$1 == ".latch"){ print $$1, $$2, $$3, "re", "top^clk", $$4 } else { print $$0 } }' > $@

$(P).arch.xml: $(ARCH)
	sed 's/#ROWS#/$(ROWS)/g' $< | sed 's/#COLS#/$(COLS)/g' > $@

$(P).route.out: $(P).awk.blif $(P).arch.xml
	$(VPR) $(P).arch.xml $(P) --nodisp --pack --place --route \
			--blif_file $(P).awk.blif \
			--fix_pins $(PADS) \
			--net_file $(P).net \
			--place_file $(P).place.out \
			--route_file $(P).route.out \
			--place_chan_width $(TRACKS) \
			--route_chan_width $(TRACKS) \
			--timing_analysis off > $(P).vpr.log
	@test -e $(P).route.out

view: $(P).awk.blif $(P).arch.xml
	$(VPR) $(P).arch.xml $(P) --pack --place --route \
			--blif_file $(P).awk.blif \
			--fix_pins $(PADS) \
			--net_file $(P).net.view \
			--place_file $(P).place.view \
			--route_file $(P).route.view \
			--place_chan_width $(TRACKS) \
			--route_chan_width $(TRACKS) \
			--timing_analysis off

$(P).done: $(P).route.out
	$(SCRIPTS)/fpga.py $(P).place.out $(P).route.out $(P).net $(P).abc.blif $(TRACKS) > $(P).bit
	touch $@

verilog: $(P).done
	$(SCRIPTS)/program_bitstream.py --file $(P).bit --dry --sim $(P).uart-tb.v

flash: $(P).done
	$(SCRIPTS)/program_bitstream.py --file $(P).bit

