module overlay (
	shift_clock,
	user_clock,
	reset,
	io_in,
	io_out,
	shift_in,
	shift_out,
	shift_enable
);

parameter LUT_INPUTS = 4;

input shift_clock;
input user_clock;
input reset;

input [LUT_INPUTS-1:0] io_in;
output io_out;

input shift_in;
input shift_enable;
output shift_out;

fpga_cell cell_inst (
	.shift_clock(clock),
	.user_clock(user_clock),
	.reset(reset),
	.inputs(io_in),
	.value(io_out),
	.shift_in(shift_in),
	.shift_out(shift_out),
	.shift_enable(shift_enable)
);


endmodule

