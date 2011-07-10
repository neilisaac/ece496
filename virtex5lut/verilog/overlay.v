`include "parameters.v"

module overlay (
	clock,
	reset,
	io_in,
	io_out,
	shift_in,
	shift_out,
	shift_enable,
);

input clock;
input reset;

input [lut_size-1:0] io_in;
output io_out;

input shift_in;
input shift_enable;
output shift_out;

fpga_cell cell_inst (
	.clock(clock),
	.reset(reset),
	.inputs(io_in),
	.value(io_out),
	.shift_in(shift_in),
	.shift_out(shift_out),
	.shift_enable(shift_enable)
);


endmodule

