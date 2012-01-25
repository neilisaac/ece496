#!/bin/sh

prefix="test"

./odin_ii -V $prefix.v -o $prefix.odin.blif > $prefix.odin.log || exit 1

./abc-vtr -f abc.cmd  > $prefix.abc.log || exit 1

cat $prefix.abc.blif | awk '{ if ($1 == ".latch"){ print $1, $2, $3, "re", "top^clk", $4; } else { print $0; } }' > $prefix.awk.blif

./t-vpack $prefix.awk.blif $prefix.net -inputs_per_cluster 16 -cluster_size 4 -lut_size 6 > $prefix.vpack.log || exit 1

./vpr $prefix.net -nodisp k6-n4.xml $prefix.place.out $prefix.route.out -fix_pins $prefix.pads -route_chan_width 4 > $prefix.vpr.log || exit 1

./fpga.py $prefix.place.out $prefix.route.out $prefix.net $prefix.abc.blif > $prefix.bit || exit 1

./program_bitstream.py --file $prefix.bit --dry --sim $prefix.uart-tb.v || exit 1

