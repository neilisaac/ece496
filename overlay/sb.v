`include "params.v"

module SWITCH_BLOCK(IN_N, IN_E, IN_S, IN_W, OUT_N, OUT_E, OUT_S, OUT_W, CLK, SE, SIN, SOUT);

parameter W = 5; //size of interconnecting bus (one way)

input [W-1:0] IN_N;
input [W-1:0] IN_E;
input [W-1:0] IN_S;
input [W-1:0] IN_W;
input CLK;
input SE;
input SIN;
output [W-1:0] OUT_N;
output [W-1:0] OUT_E;
output [W-1:0] OUT_S;
output [W-1:0] OUT_W;
output SOUT;

wire [4*W:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;
generate //generate muxes to exit to the north
	for (i=0; i<W; i=i+1) begin : OUTNMux
		SHIFTREG32 OUTNMux_inst (
			.Q(OUT_N[i]),
			.Q31(scan_chain[i+1]),
			.A({1'b0, 1'b0, IN_W[i], IN_S[i], IN_E[i]}),
			.CE(SE),
			.CLK(CLK),
			.D(scan_chain[i])
		);
	end
endgenerate

generate //generate muxes to exit to the east
	for (i=0; i<W; i=i+1) begin : OUTEMux
		SHIFTREG32 OUTEMux_inst (
			.Q(OUT_E[i]),
			.Q31(scan_chain[W+i+1]),
			.A({1'b0, 1'b0, IN_N[i], IN_W[i], IN_S[i]}),
			.CE(SE),
			.CLK(CLK),
			.D(scan_chain[W+i])
		);
	end
endgenerate

generate //generate muxes to exit to the south
	for (i=0; i<W; i=i+1) begin : OUTSMux
		SHIFTREG32 OUTSMux_inst (
			.Q(OUT_S[i]),
			.Q31(scan_chain[2*W+i+1]),
			.A({1'b0, 1'b0, IN_E[i], IN_N[i], IN_W[i]}),
			.CE(SE),
			.CLK(CLK),
			.D(scan_chain[2*W+i])
		);
	end
endgenerate

generate //generate muxes to exit to the west
	for (i=0; i<W; i=i+1) begin : OUTWMux
		SHIFTREG32 OUTWMux_inst (
			.Q(OUT_W[i]),
			.Q31(scan_chain[3*W+i+1]),
			.A({1'b0, 1'b0, IN_S[i], IN_E[i], IN_N[i]}),
			.CE(SE),
			.CLK(CLK),
			.D(scan_chain[3*W+i])
		);
	end
endgenerate

assign SOUT = scan_chain[4*W];

endmodule

