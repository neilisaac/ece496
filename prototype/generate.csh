#!/bin/tcsh -f

set rename = "output"
set proj = "evolution"
set top = "individual"
set family = "Cyclone II"
set device = "EP2C20F484C7"

if ($#argv >= 1) then
	set rename = $1
endif

set out = "$proj.qsf"
set tcl = "set_global_assignment -name"
set q = '"'

echo "creating $out"
cat /dev/null > $out
echo "$tcl PROJECT_CREATION_TIME_DATE $q`date '+%T  %B %d, %Y'`$q" >> $out
echo "$tcl TOP_LEVEL_ENTITY $top" >> $out
echo "$tcl FAMILY $q$family$q" >> $out
echo "$tcl DEVICE $q$device$q" >> $out
echo "$tcl VERILOG_FILE $top.v" >> $out
echo "$tcl CYCLONEII_OPTIMIZATION_TECHNIQUE AREA" >> $out
echo "$tcl SYNTHESIS_EFFORT FAST" >> $out
echo "$tcl ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON" >> $out
echo "$tcl TRUE_WYSIWYG_FLOW ON" >> $out
echo "$tcl IGNORE_PARTITIONS ON" >> $out

set echo

./synthesize_cells.py \
	--file $top.v \
	--module $top \
	--input PIN_A13 \
	--output PIN_B13 \
	--cells 100 || exit 1

quartus_map $proj || exit 1
quartus_cdb $proj --vqm=$top.vqm

quartus_fit $proj || exit 1
quartus_cdb $proj --back_annotate=lab
quartus_cdb $proj --back_annotate=routing

quartus_asm $proj || exit 1

#quartus_pgm -c USB_Blaster -m JTAG -o "P;$proj.sof" || exit 1

unset echo

echo saving result to $rename.tgz and $rename.sof

mv $proj.sof $rename.sof
rm -f $proj.pof
tar czf $rename.tgz $proj.* $top.*
rm -rf db incremental_db $proj.* $top.*

