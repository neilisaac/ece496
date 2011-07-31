# project specific options
PROJ=serial_test
TOP=master
VERILOG=ble.v decoder.v delay.v master.v transition.v uart.v
UCF=pins.ucf

# target specific options
PART=xc5vlx110t-ff1136-1
ARCH=virtex5

# default is to generate the bitstream
bitstream: $(PROJ).bit

# named targets
prj: $(PROJ).prj
parse: $(PROJ).xst.ncd
build: $(PROJ).ngd
map: $(PROJ).map.ncd
par: $(PROJ).par.ncd

# generate project file
$(PROJ).prj: $(VERILOG)
	echo -n "" > $@
	@for file in $(shell echo $(VERILOG)) ; do echo "verilog work \"$$file\"" >> $@ ; done

# run xst to parse verilog source
$(PROJ).xst.ngc: $(PROJ).prj
	@echo "run -ifn $(PROJ).prj -ofn $@ -top $(TOP) -p $(PART) -verilog2001 yes -opt_mode SPEED -opt_level 1" > $(PROJ).xst.scr
	xst -ifn $(PROJ).xst.scr -ofn $(PROJ).xst.log || rm -f $@ && exit 1

# create native generic database
$(PROJ).ngd: $(PROJ).xst.ngc
	ngdbuild -p $(PART) -uc $(UCF) $< $@ || rm -f $@ && exit 1

# run synthesis
$(PROJ).map.ncd: $(PROJ).ngd
	map -p $(PART) -o $@ $< || rm -f $@ && exit 1

# run place and route
$(PROJ).par.ncd: $(PROJ).map.ncd
	par $< $@ || rm -f $@ && exit 1

# create bitstream
$(PROJ).bit: $(PROJ).par.ncd
	bitgen $< $@ || rm -f $@ && exit 1

# flash bitstream to device
flash: $(PROJ).par.ncd
	@printf "setMode -bscan\nsetCable -p auto\nidentify\nassignFile -p 5 -file $(PROJ).bit\nprogram -p 5\nquit\n" > $(PROJ).impact.scr
	impact -batch $(PROJ).impact.scr

# cleanup target
clean:
	rm -rf $(PROJ).prj $(PROJ).*.ncd $(PROJ).ngd $(PROJ).bgn $(PROJ).bit $(PROJ)_bitgen.xwbt $(PROJ).bld $(PROJ).drc $(PROJ).map $(PROJ).map.map $(PROJ).map.mrp $(PROJ).map.ngm $(PROJ).map.pcf $(PROJ).mrp $(PROJ).ngc $(PROJ).ngc_xst.xrpt $(PROJ)_ngdbuild.xrpt $(PROJ).ngm $(PROJ).par.pad $(PROJ).par_pad.csv $(PROJ).par_pad.txt $(PROJ).par.par $(PROJ).par.ptwx $(PROJ).par.unroutes $(PROJ).par.xpi $(PROJ).pcf $(PROJ).prj $(PROJ)_summary.xml $(PROJ)_usage.xml $(PROJ).xst.log $(PROJ).xst.scr $(PROJ).xst.ngc_xst.xrpt $(PROJ).xst.ngc $(PROJ).impact.scr $(TOP)_map.xrpt $(TOP)_par.xrpt $(TOP).lso netlist.lst usage_statistics_webtalk.html webtalk.log _impactbatch.log xlnx_auto_0_xdb _xmsgs xst

.PHONY: parse map par bitstream flash clean

