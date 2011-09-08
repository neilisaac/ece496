module XBAR2LAYER(A, CE, CLK, SIN, Z, SOUT);

parameter N = 25; //number of inputs desired, max = 25
parameter lay1 = N/5+(N%5 == 0 ? 0 : 1); //# of LUTs in the first layer

input [N-1:0] A;
input CE;
input CLK;
input SIN;
output Z;
output SOUT;

wire [lay1*5-1:0] inputs = A;

wire [lay1-1:0] b; //output bus from layer 1 (sized according to number of inputs in layer 2)
wire [lay1:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;

//generate first layer: ceil(N/5) LUTs
generate
	 for (i=0; i<lay1; i=i+1) begin : SR321
		SRLC32E #(
		.INIT(32'h80000000) // Initial Value of Shift Register
		) L1A (
		.Q(b[i]), // SRL data output
		.Q31(scan_chain[i+1]), // SRL cascade output pin
		.A(inputs[(i*5+4):(i*5)]), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[i]) // SRL data input
		);
		// End of SRLC32E_inst instantiation
	 end
endgenerate

//final layer
SRLC32E #(
.INIT(32'h80000000) // Initial Value of Shift Register
) W (
.Q(Z), // SRL data output
.Q31(SOUT), // SRL cascade output pin
.A(b), // 5-bit shift depth select input
.CE(CE), // Clock enable input
.CLK(CLK), // Clock input
.D(scan_chain[lay1]) // SRL data input
);
// End of SRLC32E_inst instantiation

endmodule
