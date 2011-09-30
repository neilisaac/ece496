module XBAR1LAYER(
	input [4:0] A,
	input CE,
	input CLK,
	input SIN,
	output Z,
	output SOUT
);

SRLC32E #( .INIT(32'h80000000) ) mux_inst (
	.Q(Z),
	.Q31(SOUT),
	.A(A),
	.CE(CE),
	.CLK(CLK),
	.D(SIN)
);

endmodule

