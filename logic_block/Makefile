# project specific options
PROJ=logic_block
TOP=MASTER
VERILOG=master.v lb.v ble.v decoder.v delay.v transition.v uart.v xbar2layer.v
UCF=pins.ucf
PART=xc5vlx110t-ff1136-1

# default is to generate the bitstream
bitstream: $(PROJ).bit

# named targets
prj: $(PROJ).prj
parse: $(PROJ).xst.ngc
build: $(PROJ).ngd
map: $(PROJ).map.ncd
par: $(PROJ).par.ncd

# generate project file
$(PROJ).prj: $(VERILOG)
	@echo === creating project file ===
	@echo -n "" > $@
	@for file in $(shell echo $^) ; do echo "verilog work \"$$file\"" >> $@ ; done
	@echo generated $(PROJ).prj
	@echo

# run xst to parse verilog source
$(PROJ).xst.ngc: $(PROJ).prj
	@echo === running xst ===
	@rm -f $@
	@echo "run -ifn $(PROJ).prj -ofn $@ -top $(TOP) -p $(PART) -verilog2001 yes -opt_mode SPEED -opt_level 1" > $(PROJ).xst.scr
	xst -ifn $(PROJ).xst.scr > $(PROJ).xst.log 2>&1
	@grep -E 'ERROR|WARNING' $(PROJ).xst.log || true
	@echo

# create native generic database
$(PROJ).ngd: $(PROJ).xst.ngc $(UCF)
	@echo === running ngdbuild ===
	@rm -f $@
	ngdbuild -p $(PART) -uc $(UCF) $< $@ > $(PROJ).ngdbuild.log 2>&1
	@grep -E 'ERROR|WARNING' $(PROJ).ngdbuild.log || true
	@echo

# run synthesis
$(PROJ).map.ncd: $(PROJ).ngd
	@echo === running map ===
	@rm -f $@
	map -p $(PART) -o $@ $< > $(PROJ).map.log 2>&1
	@grep -E 'ERROR|WARNING' $(PROJ).map.log || true
	@echo

# run place and route
$(PROJ).par.ncd: $(PROJ).map.ncd
	@echo === running par ===
	@rm -f $@
	par $< $@ > $(PROJ).par.log 2>&1
	@grep -E 'ERROR|WARNING' $(PROJ).par.log || true
	@echo

# create bitstream
$(PROJ).bit: $(PROJ).par.ncd
	@echo === running bitgen ===
	@rm -f $@
	bitgen -w $< $@ > $(PROJ).bitgen.log 2>&1
	@grep -E 'ERROR|WARNING' $(PROJ).bitgen.log || true
	@echo

# view design in fpga_editor
view: $(PROJ).par.ncd
	@echo === running fpga_editor ===
	fpga_editor $<
	@echo

# flash bitstream to device
flash: $(PROJ).bit
	@echo === running impact ===
	@printf "setMode -bscan\nsetCable -p auto\nidentify\nassignFile -p 5 -file $(PROJ).bit\nprogram -p 5\nquit\n" > $(PROJ).impact.scr
	impact -batch $(PROJ).impact.scr > $(PROJ).impact.log 2>&1
	@grep -E 'ERROR|WARNING' $(PROJ).impact.log || true
	@echo

# cleanup target
clean:
	rm -rf $(PROJ).prj $(PROJ).*.log $(PROJ).*.ncd $(PROJ).ngd $(PROJ).bgn $(PROJ).bit $(PROJ)_bitgen.xwbt $(PROJ).bld $(PROJ).drc $(PROJ).map $(PROJ).map.map $(PROJ).map.mrp $(PROJ).map.ngm $(PROJ).map.pcf $(PROJ).mrp $(PROJ).ngc $(PROJ).ngc_xst.xrpt $(PROJ)_ngdbuild.xrpt $(PROJ).ngm $(PROJ).par.pad $(PROJ).par_pad.csv $(PROJ).par_pad.txt $(PROJ).par.par $(PROJ).par.ptwx $(PROJ).par.unroutes $(PROJ).par.xpi $(PROJ).pcf $(PROJ).prj $(PROJ)_summary.xml $(PROJ)_usage.xml $(PROJ).xst.scr $(PROJ).xst.ngc_xst.xrpt $(PROJ).xst.srp $(PROJ).xst.ngc $(PROJ).impact.scr $(TOP)_map.xrpt $(TOP)_par.xrpt $(TOP).lso netlist.lst usage_statistics_webtalk.html webtalk.log _impactbatch.log xlnx_auto_0_xdb _xmsgs xst

.PHONY: parse map par bitstream view flash clean

