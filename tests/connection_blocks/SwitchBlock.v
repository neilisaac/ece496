module SwitchBlock(IN_N, IN_E, IN_S, IN_W, OUT_N, OUT_E, OUT_S, OUT_W, CLK, CE, SIN, SOUT
    );
parameter W = 5; //size of interconnecting bus (one way)

input [W-1:0] IN_N;
input [W-1:0] IN_E;
input [W-1:0] IN_S;
input [W-1:0] IN_W;
input CLK;
input CE;
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
		SRLC32E #(
		.INIT(32'hCCCCCCCC) // Initial Value of Shift Register
		) OUTNMux_inst (
		.Q(OUT_N[i]), // SRL data output
		.Q31(scan_chain[i+1]), // SRL cascade output pin
		.A({0, 0, IN_W[i], IN_S[i], IN_E[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the east
	for (i=0; i<W; i=i+1) begin : OUTEMux
		SRLC32E #(
		.INIT(32'hAAAAAAAA) // Initial Value of Shift Register
		) OUTEMux_inst (
		.Q(OUT_E[i]), // SRL data output
		.Q31(scan_chain[W+i+1]), // SRL cascade output pin
		.A({0, 0, IN_N[i], IN_W[i], IN_S[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[W+i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the south
	for (i=0; i<W; i=i+1) begin : OUTSMux
		SRLC32E #(
		.INIT(32'hAAAAAAAA) // Initial Value of Shift Register
		) OUTSMux_inst (
		.Q(OUT_S[i]), // SRL data output
		.Q31(scan_chain[2*W+i+1]), // SRL cascade output pin
		.A({0, 0, IN_E[i], IN_N[i], IN_W[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[2*W+i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the west
	for (i=0; i<W; i=i+1) begin : OUTWMux
		SRLC32E #(
		.INIT(32'hAAAAAAAA) // Initial Value of Shift Register
		) OUTWMux_inst (
		.Q(OUT_W[i]), // SRL data output
		.Q31(scan_chain[3*W+i+1]), // SRL cascade output pin
		.A({0, 0, IN_S[i], IN_E[i], IN_N[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[3*W+i]) // SRL data input
		);
	end
endgenerate

assign SOUT = scan_chain[4*W];

endmodule
