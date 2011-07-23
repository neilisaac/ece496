module ble (
	input [5:0]A,
	input PCLK,
	input UCLK,
	input SE,
	input SIN,
	output SOUT,
	output F
);


wire q1, q2;
wire scan1, scan2;

SRLC32E #(
.INIT(32'h00000000)
) lut_inst1 (
	.Q(q1), // SRL data output
	.Q31(scan1), // SRL cascade output pin
	.A(A[4:0]), // 5-bit shift depth select input
	.CE(SE), // Clock enable input
	.CLK(PCLK), // Clock input
	.D(SIN) // SRL data input
);

SRLC32E #(
.INIT(32'h00000000)
) lut_inst2 (
	.Q(q2), // SRL data output
	.Q31(scan2), // SRL cascade output pin
	.A(A[4:0]), // 5-bit shift depth select input
	.CE(SE), // Clock enable input
	.CLK(PCLK), // Clock input
	.D(scan1) // SRL data input
);


wire q;

// Use F7 mux to select between the two 32-bit shift registers
MUXF7 shift_select_mux (
	.O(q),
	.I0(q1),
	.I1(q2),
	.S(A[5])
);


reg select;
always @ (posedge PCLK)
	if (SE)
		select <= scan2;

assign SOUT = select;


reg flop_value;
always @ (posedge UCLK)
	flop_value <= q;

assign F = select ? flop_value : q;


endmodule
