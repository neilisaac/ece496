module ble (
	input [4:0]A,
	input PCLK,
	input UCLK,
	input SE,
	input SIN,
	output SOUT,
	output F
	);

wire q1;
wire scan1;

SRLC32E #(
.INIT(32'h00000000)
) lut_inst (
	.Q(q1), // SRL data output
	.Q31(scan1), // SRL cascade output pin
	.A(A), // 5-bit shift depth select input
	.CE(SE), // Clock enable input
	.CLK(PCLK), // Clock input
	.D(SIN) // SRL data input
);

reg select;
always @ (posedge PCLK)
	if (SE)
		select <= scan1;

assign SOUT = select;

reg flop_value;
always @ (posedge UCLK)
	flop_value <= q1;
	
assign F = select ? flop_value : q1;

endmodule
