module ble (
	input [4:0]A,
	input PCLK,
	input UCLK,
	input SE,
	input SIN,
	output SOUT,
	output F
	);

wire q;
wire scan_internal;

SRLC32E #(
.INIT(32'h00000000)
) lut_inst (
	.Q(q), // SRL data output
	.Q31(scan_internal), // SRL cascade output pin
	.A(A), // 5-bit shift depth select input
	.CE(SE), // Clock enable input
	.CLK(PCLK), // Clock input
	.D(SIN) // SRL data input
);

reg select;

always@(posedge PCLK)
	if(SE)
		select<=scan_internal;

assign SOUT=select;

reg flop_inst;

always@(posedge UCLK)
	flop_inst<=q;
	
assign F=select?flop_inst:q;

endmodule
