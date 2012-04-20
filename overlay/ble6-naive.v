`include "params.v"

// this in an "intuitive" or "naive" implementation that
// is inefficient on modern architectures
module BLE6 (
	input [5:0]A,
	input PCLK,
	input PRST,
	input UCLK,
	input URST,
	input SE,
	input SIN,
	output SOUT,
	output F
);

// LUT bits
reg [63:0] bits;

// Program the LUT serially
always @ (posedge PCLK)
	if (SE) bits <= { bits[63:0], SIN };

// LUT multiplexer
assign logic_value = bits[A];


// User flip-flop
reg flop_value;
always @ (posedge UCLK or posedge URST)
	if (URST)
		flop_value <= 0;
	else
		flop_value <= logic_value;


// Output selection mux control value
reg select;
always @ (posedge PCLK)
	if (PRST)
		select <= 0;
	else if (SE)
		select <= bits[31];


// Output selection mux
assign F = select ? flop_value : logic_value;


// Scan out signal chained off from mux control value
assign SOUT = select;


endmodule

