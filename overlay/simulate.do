vlib work
vlog *.v
vsim work.testbench -voptargs="+acc"
add wave /*
add wave /testbench/overlat_inst/*
run 30us
