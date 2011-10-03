module XBAR3LAYER(A, SE, CLK, SIN, Z, SOUT);

parameter N = 125; //number of inputs desired, max = 125 (if under 26, use the 2-layer mux instead)
parameter lay1 = N/5+(N%5 == 0 ? 0 : 1); //# of LUTs in the first layer
parameter lay2 = lay1/5+(lay1%5 == 0 ? 0 : 1); //# of LUTs in the second layer

input [N-1:0] A;
input SE;
input CLK;
input SIN;
output Z;
output SOUT;

wire [lay1*5-1:0] inputs = A;

wire [(lay2*5)-1:0] b; //output bus from layer 1 (sized according to number of inputs in layer 2)
wire [lay2-1:0] c; //output bus from layer 2
wire [lay1+lay2:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;

//generate first layer: ceil(N/5) LUTs
generate
	 for (i=0; i<lay1; i=i+1) begin : SR321
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) L1A (
		.Q(b[i]), // SRL data output
		.Q31(scan_chain[i+1]), // SRL cascade output pin
		.A(inputs[(i*5+4):(i*5)]), // 5-bit shift depth select input
		.CE(SE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[i]) // SRL data input
		);
		// End of SRLC32E_inst instantiation
	 end
endgenerate

//generate second layer: ceil(ceil(N/5)/5) LUTs
generate
	 for (i=0; i<lay2; i=i+1) begin : SR322
		SRLC32E #(
		.INIT(32'h00000000) // Initial Value of Shift Register
		) L2A (
		.Q(c[i]), // SRL data output
		.Q31(scan_chain[lay1+i+1]), // SRL cascade output pin
		.A(b[(i*5+4):(i*5)]), // 5-bit shift depth select input
		.CE(SE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[lay1+i]) // SRL data input
		);
		// End of SRLC32E_inst instantiation
	 end
endgenerate

//final layer
SRLC32E #(
.INIT(32'h00000000) // Initial Value of Shift Register
) W (
.Q(Z), // SRL data output
.Q31(SOUT), // SRL cascade output pin
.A(c), // 5-bit shift depth select input
.CE(SE), // Clock enable input
.CLK(CLK), // Clock input
.D(scan_chain[lay1+lay2]) // SRL data input
);
// End of SRLC32E_inst instantiation

endmodule

