#!/bin/sh

./odin_ii -V test.v -o test.odin.blif

./abc-287 -f abc.cmd

cat test.abc.blif | awk '{ if ($1 == ".latch"){ print $1, $2, $3, "re", "top^clk", $4; } else { print $0; } }' > test.awk.blif

./t-vpack test.awk.blif test.net -inputs_per_cluster 20 -cluster_size 4 -lut_size 6


exit 0
./vpr test.net k4-n10.xml place.out route.out

