#!/bin/sh

./t-vpack test.blif test.net -inputs_per_cluster 20 -cluster_size 4 -lut_size 6

./vpr test.net k4-n10.xml place.out route.out

