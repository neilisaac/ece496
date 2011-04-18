#!/bin/tcsh -f

set rename = "output"
set proj = "evolution"
set module = "individual"
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
echo "$tcl TOP_LEVEL_ENTITY $module" >> $out
echo "$tcl FAMILY $q$family$q" >> $out
echo "$tcl DEVICE $q$device$q" >> $out
echo "$tcl VERILOG_FILE $module.v" >> $out
echo "$tcl CYCLONEII_OPTIMIZATION_TECHNIQUE AREA" >> $out
echo "$tcl SYNTHESIS_EFFORT FAST" >> $out
echo "$tcl TRUE_WYSIWYG_FLOW ON" >> $out
echo "$tcl ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON" >> $out
#echo "$tcl IGNORE_PARTITIONS ON" >> $out

set echo

./synthesize_cells.py \
	--verilog $module.v \
	--module $module \
	--csv $module.csv \
	--place $module.place \
	--min-x 5 --max-x 12 \
	--min-y 3 --labs 2,10,18,26 \
	--input PIN_A13 \
	--output PIN_B13 \
	--cells 128 || exit 1

# complete functional synthesis
quartus_map $proj || exit 1

## get synthesized instance names and fix them
#quartus_cdb $proj --vqm=$module.vqm
#
#./fix_placement.py $module.vqm $proj.place \
#	--instance-patterns "table" --cell cycloneii_lcell_comb \
#	--min-x 19 --min-y 2 --max-x 26 \
#	--fix-luts --luts-per-lab 3 || exit 1

# append placement information to the project file
cat $module.place >> $proj.qsf

## need to delete the synthesized verilog first
#rm $module.vqm 

# run placement and routing, then produce output files
quartus_fit $proj || exit 1
quartus_asm $proj || exit 1

## program board
#quartus_pgm -c USB_Blaster -m JTAG -o "P;$proj.sof" || exit 1

## back-annotate results for debugging
#quartus_cdb $proj --vqm=$module.vqm
#quartus_cdb $proj --back_annotate=lab
#quartus_cdb $proj --back_annotate=routing

unset echo

echo saving result to $rename.tgz and $rename.sof
mv $proj.sof $rename.sof

# clean up
rm -f $proj.pof
#tar czf $rename.tgz $proj.* $module.*
#rm -rf db incremental_db

