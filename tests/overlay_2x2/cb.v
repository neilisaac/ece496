module # (
		parameter W2 = 5,
		parameter L2 = 1,
	) CONNECTION_BLOCK (
		input PCLK, PRST, SE, SIN,
		input [W2-1:0] SW_IN1, SW_IN2,
		input [L2-1:0] LB_IN1, LB_IN2,
		output [W2-1:0] SW_OUT1, SW_OUT2,
		output [L2-1:0] LB_OUT1, LB_OUT2,
		output SOUT
	);

wire [2*W2+2*L2:0] scan;
assign scan[0] = SIN;
assign SOUT = scan[2*W2+2*L2];

genvar i;
generate
	for (i = 0; i < W2; i = i+1) begin : W_SWITCH
		wire [2:0] SET1, SET2;

	end
endgenerate

endmodule

