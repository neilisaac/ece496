// module to create N:1 static multiplexer using shift registers
// to control the selected signal (6 <= N <= 25)
module XBAR2LAYER(A, SE, CLK, SIN, Z, SOUT);

parameter N = 25; // number of inputs desired, max = 25
parameter lay1 = N/5+(N%5 == 0 ? 0 : 1); // # of LUTs in the first layer = ceil(N/5)

input [N-1:0] A;
input SE;
input CLK;
input SIN;
output Z;
output SOUT;

wire [4:0] b; // output bus from layer 1 (sized according to number of inputs in layer 2)
wire [lay1:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;

// this loop generates ceil(N/5) <= 5 shift registers to multiplex the N inputs from A 
generate
	for (i = 0; i < 5; i = i+1) begin : SR321
		if (i < lay1)
			SHIFTREG32 L1A (
				.Q(b[i]),
				.Q31(scan_chain[i+1]),
				.A(A[(i * 5 + 4 < N ? i * 5 + 4 : N - 1):(i * 5)]),
				.CE(SE),
				.CLK(CLK),
				.D(scan_chain[i])
			);
		else
			assign b[i] = 0;
	 end
endgenerate

// create 1 more shift register to multiplex the first layer shift register
// outputs
SHIFTREG32 W (
	.Q(Z), // SRL data output
	.Q31(SOUT), // SRL cascade output pin
	.A(b), // 5-bit shift depth select input
	.CE(SE), // Clock enable input
	.CLK(CLK), // Clock input
	.D(scan_chain[lay1]) // SRL data input
);

endmodule

