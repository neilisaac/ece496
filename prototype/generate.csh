#!/bin/tcsh -f

set scripts = "."
set proj = "evolution"
set top = "fitness"
set module = "individual"
set prefix = "tester:test|${module}:mutant|"
set files = "tester delay hex_digits uart"
set family = "Cyclone II"
set device = "EP2C20F484C7"

if ($#argv >= 1) then
	set rename = $1
endif

# delete old files
rm -rf db incremental_db $proj.* $module.*

set out = "$proj.qsf"
set tcl = "set_global_assignment -name"
set q = '"'

echo "creating $out"
cat /dev/null > $out
echo "$tcl PROJECT_CREATION_TIME_DATE $q`date '+%T  %B %d, %Y'`$q" >> $out
echo "$tcl TOP_LEVEL_ENTITY $top" >> $out
echo "$tcl FAMILY $q$family$q" >> $out
echo "$tcl DEVICE $q$device$q" >> $out
echo "$tcl SYNTHESIS_EFFORT FAST" >> $out
echo "$tcl ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON" >> $out
echo "$tcl VERILOG_FILE $top.v" >> $out
echo "$tcl VERILOG_FILE $module.v" >> $out
foreach file ($files)
	echo "$tcl VERILOG_FILE $file.v" >> $out
end

## this seems to actually be for HardCopy (but not 100% sure)
#echo "$tcl TRUE_WYSIWYG_FLOW ON" >> $out

# add DE1 pin definitions to project file
cat pins.tcl >> $out

set echo

# generate mutant instance
$scripts/synthesize_cells.py \
	--verilog "$module.v" \
	--module "$module" \
	--prefix "$prefix" \
	--csv "$module.csv" \
	--place "$module.place" \
	--cells 128 \
	--min-x 5 --max-x 12 \
	--min-y 3 --labs 2,10,18,26 \
	--inputs in1 \
	--outputs out1 \
	--tie-unused || exit 1

# complete functional synthesis
quartus_map $proj || exit 1

# append placement information to the project file
cat $module.place >> $proj.qsf

# run placement and routing, then produce output files
quartus_fit $proj || exit 1
quartus_asm $proj || exit 1

## back-annotate results for debugging
#quartus_cdb $proj --vqm=$module.vqm
#quartus_cdb $proj --back_annotate=lab
#quartus_cdb $proj --back_annotate=routing

# clean up
rm -f $proj.pof
#tar czf $rename.tgz $proj.* $module.*
#rm -rf db incremental_db

## program board
quartus_pgm -c USB-Blaster -m JTAG -o "P;$proj.sof" || exit 1

