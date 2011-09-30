module # (
		parameter W2 = 5,
	) SWITCH_BLOCK (
		input PCLK, PRST, SE, SIN,
		input [W2-1:0] IN_N, IN_E, IN_S, IN_W,
		output [W2-1:0] OUT_N, OUT_E, OUT_S, OUT_W,
		output SOUT
	);

wire [4*W2:0] scan;
assign scan[0] = SIN;
assign SOUT = scan[4*W2];

genvar i;
generate
	for (i = 0; i < W2; i = i+1) begin : SWITCH
		wire [2:0] SET_N, SET_S, SET_E, SET_W;

		assign SET_N = { IN_E[i], IN_S[i], IN_W[i] };
		XBAR1LAYER mux_n(SET_N, SE, PCLK, scan[4*i+0], OUT_N[i], scan[4*i+1]);
		
		assign SET_E = { IN_S[i], IN_W[i], IN_N[i] };
		XBAR1LAYER mux_e(SET_E, SE, PCLK, scan[4*i+1], OUT_E[i], scan[4*i+2]);

		assign SET_S = { IN_W[i], IN_N[i], IN_E[i] };
		XBAR1LAYER mux_s(SET_S, SE, PCLK, scan[4*i+2], OUT_S[i], scan[4*i+3]);

		assign SET_W = { IN_N[i], IN_E[i], IN_S[i] };
		XBAR1LAYER mux_w(SET_W, SE, PCLK, scan[4*i+3], OUT_W[i], scan[5*i+0]);
	end
endgenerate

endmodule

