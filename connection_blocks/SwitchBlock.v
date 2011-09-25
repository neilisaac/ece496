module SwitchBlock(IN_N, IN_E, IN_S, IN_W, OUT_N, OUT_E, OUT_S, OUT_W, CLK, CE, SIN, SOUT
    );
parameter N = 4; //size of interconnecting bus (one way)

input [N-1:0] IN_N;
input [N-1:0] IN_E;
input [N-1:0] IN_S;
input [N-1:0] IN_W;
output [N-1:0] OUT_N;
output [N-1:0] OUT_E;
output [N-1:0] OUT_S;
output [N-1:0] OUT_W;

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

SRL16E #(
.INIT(16'h0000) // Initial Value of Shift Register
) SRL16E_inst (
.Q(Q), // SRL data output
.A0(A0), // Select[0] input
.A1(A1), // Select[1] input
.A2(A2), // Select[2] input
.A3(A3), // Select[3] input
.CE(CE), // Clock enable input
.CLK(CLK), // Clock input
.D(D) // SRL data input
);

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

generate //generate muxes to exit to the north
	for (i=0; i<N; i=i+1) begin : OUTNMux
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) OUTNMux_inst (
		.Q(OUT_S[i]), // SRL data output
		.Q31(scan_chain[2*N+i+1]), // SRL cascade output pin
		.A({IN_N[i], IN_E[i], IN_W[i]}), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[2*N+i]) // SRL data input
		);
	end
endgenerate

generate //generate muxes to exit to the north
	for (i=0; i<N; i=i+1) begin : OUTNMux
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) OUTNMux_inst (
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
