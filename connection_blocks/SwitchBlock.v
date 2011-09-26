module SwitchBlock(IN_N, IN_E, IN_S, IN_W, OUT_N, OUT_E, OUT_S, OUT_W, CLK, CE, SIN, SOUT
    );
parameter N = 5; //size of interconnecting bus (one way)

input [N-1:0] IN_N;
input [N-1:0] IN_E;
input [N-1:0] IN_S;
input [N-1:0] IN_W;
input CLK;
input CE;
input SIN;
output [N-1:0] OUT_N;
output [N-1:0] OUT_E;
output [N-1:0] OUT_S;
output [N-1:0] OUT_W;
output SOUT;

wire [4*N:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;
generate //generate muxes to exit to the north
	for (i=0; i<N; i=i+1) begin : OUTNMux
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) OUTNMux_inst (
		.Q(OUT_N[i]), // SRL data output
		.Q31(scan_chain[i+1]), // SRL cascade output pin
		.A({IN_E[i], IN_S[i], IN_W[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the east
	for (i=0; i<N; i=i+1) begin : OUTEMux
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) OUTEMux_inst (
		.Q(OUT_E[i]), // SRL data output
		.Q31(scan_chain[N+i+1]), // SRL cascade output pin
		.A({IN_N[i], IN_S[i], IN_W[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[N+i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the south
	for (i=0; i<N; i=i+1) begin : OUTSMux
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) OUTSMux_inst (
		.Q(OUT_S[i]), // SRL data output
		.Q31(scan_chain[2*N+i+1]), // SRL cascade output pin
		.A({IN_N[i], IN_E[i], IN_W[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[2*N+i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the west
	for (i=0; i<N; i=i+1) begin : OUTWMux
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) OUTWMux_inst (
		.Q(OUT_W[i]), // SRL data output
		.Q31(scan_chain[3*N+i+1]), // SRL cascade output pin
		.A({IN_N[i], IN_E[i], IN_S[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[3*N+i]) // SRL data input
		);
	end
endgenerate

assign SOUT = scan_chain[4*N];

endmodule
