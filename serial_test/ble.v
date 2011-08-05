module BLE (
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


// Shift register used as virtual lookup table
wire q1, scan1;
SRLC32E #(
.INIT(32'h00000000)
) lut_inst1 (
	.Q(q1),			// SRL data output
	.Q31(scan1),	// SRL cascade output pin
	.A(A[4:0]),		// 5-bit shift depth select input
	.CE(SE),		// Clock enable input
	.CLK(PCLK),		// Clock input
	.D(SIN)			// SRL data input
);

wire q2, scan2;
SRLC32E #(
.INIT(32'h00000000)
) lut_inst2 (
	.Q(q2),
	.Q31(scan2),
	.A(A[4:0]),
	.CE(SE),
	.CLK(PCLK),
	.D(scan1)
);


// Use F7 mux to select between the two 32-bit shift registers
wire logic_value;
MUXF7 shift_select_mux (
	.O(logic_value),
	.I0(q1),
	.I1(q2),
	.S(A[5])
);


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
		select <= scan2;


// Output selection mux
assign F = select ? flop_value : logic_value;


// Scan out signal chained off from mux control value
assign SOUT = select;


endmodule

