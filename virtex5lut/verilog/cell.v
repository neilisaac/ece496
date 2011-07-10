`include "parameters.v"

module fpga_cell (
	shift_clock,
	user_clock,
	reset,
	inputs,
	shift_in,
	shift_enable,
	value,
	shift_out
);

input user_clock, shift_clock, reset;
input [lut_size-1:0] inputs;
input shift_in, shift_enable;
output value;
output shift_out;



// define "virtual" lookup table instance

wire lut_value;
wire [5:0] lut_input = inputs;

// RAM64X1S: 64 x 1 positive edge write, asynchronous read single-port distributed RAM
// Xilinx HDL Libraries Guide, version 13.2
RAM64X1S # (
	.INIT(64'h0000000000000000) // Initial contents of RAM
) virtual_lut (
	.O(lut_value),		// 1-bit data output
	.A0(lut_input[0]),	// Address[0] input bit
	.A1(lut_input[1]),	// Address[1] input bit
	.A2(lut_input[2]),	// Address[2] input bit
	.A3(lut_input[3]),	// Address[3] input bit
	.A4(lut_input[4]),	// Address[4] input bit
	.A5(lut_input[5]),	// Address[5] input bit
	.D(shift_in),		// 1-bit data input
	.WCLK(shift_clock),	// Write clock input
	.WE(shift_enable)	// Write enable input
);



// define BLE flop

reg flop_value;

always @ (posedge shift_clock or posedge reset)
	if (reset)
		// user global reset signal
		flop_value <= 0;
	else
		// standard operation
		flop_value <= lut_value;




// define output selection circuit

reg output_select;

always @ (posedge clock)
	if (shift_enable)
		output_select <= lut_value;

// output of BLE is MUXed between lut value and flop value
assign value = output_select ? lut_value : flop_value;

//shift chain is: shift_in -> virtual lut -> output_select -> shift_out
assign shift_out = output_select;



endmodule

