module XBAR2LAYER(input [24:0] A, input SE, input CLK, input SIN, output Z, output SOUT);

parameter N = 25; //number of inputs desired, max = 25
parameter lay1 = N/5+(N%5 == 0 ? 0 : 1); //# of LUTs in the first layer

//Making a 2-layer mux with 5 LUTs:
//(N/5+(N%5 == 0 ? 0 : 1)) = # of LUTs in first layer
//(N/5-(N%5 == 0 ? 1 : 0)) = # of LUTs in first layer -1

wire [4:0] b; //output bus from layer 1 (sized according to number of inputs in layer 2)
wire [lay1:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;

//generate first layer: ceil(N/5) LUTs
generate
	 for (i=0; i<lay1; i=i+1) begin : SR321
		SHIFTREG32 L1A (
		.Q(b[i]), // SRL data output
		.Q31(scan_chain[i+1]), // SRL cascade output pin
		.A(A[(i*5+4):(i*5)]), // 5-bit shift depth select input
		.CE(SE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[i]) // SRL data input
		);
		// End of SHIFTREG32_inst instantiation
	 end
endgenerate

//final layer
SHIFTREG32 W (
.Q(Z), // SRL data output
.Q31(SOUT), // SRL cascade output pin
.A(b), // 5-bit shift depth select input
.CE(SE), // Clock enable input
.CLK(CLK), // Clock input
.D(scan_chain[lay1]) // SRL data input
);
// End of SHIFTREG32_inst instantiation

endmodule

