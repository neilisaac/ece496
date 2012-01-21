#!/bin/sh

./odin_ii -V test.v -o test.odin.blif

./abc-vtr -f abc.cmd || exit 1

cat test.abc.blif | awk '{ if ($1 == ".latch"){ print $1, $2, $3, "re", "top^clk", $4; } else { print $0; } }' > test.awk.blif

./t-vpack test.awk.blif test.net -inputs_per_cluster 16 -cluster_size 4 -lut_size 6 || exit 1

./vpr test.net -nodisp k6-n4.xml place.out route.out  -route_chan_width 4 || exit 1

./fpga.py place.out route.out test.net test.abc.blif > test.bit || exit 1

./program_bitstream.py --file test.bit --dry --sim test.uart-tb.v || exit 1

