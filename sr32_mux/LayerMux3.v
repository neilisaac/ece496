module LayerMux3(input [124:0] A, input CE, input CLK, input D, output Z, output Q);

parameter N = 125; //number of inputs desired, max = 125 (if under 26, use the 2-layer mux instead)
parameter lay1 = N/5+(N%5 == 0 ? 0 : 1); //# of LUTs in the first layer
parameter lay2 = lay1/5+(lay1%5 == 0 ? 0 : 1); //# of LUTs in the second layer

//Making a 3-layer mux with 5 LUTs:
//(N/5+(N%5 == 0 ? 0 : 1)) = # of LUTs in first layer
//(N/5-(N%5 == 0 ? 1 : 0)) = # of LUTs in first layer -1
//((N/5+(N%5 == 0 ? 0 : 1))/5+((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 0 : 1)) = # of LUTs in second layer
//((N/5+(N%5 == 0 ? 0 : 1))/5-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 1 : 0)) = # of LUTs in second layer -1

wire [(lay2*5)-1:0] b; //output bus from layer 1 (sized according to number of inputs in layer 2)
wire [lay2-1:0] c; //output bus from layer 2
wire [lay1+lay2:0] scan_chain;

assign scan_chain[0] = D;

genvar i;

//generate first layer: ceil(N/5) LUTs
generate
	 for (i=0; i<lay1; i=i+1) begin : SR321
		SRLC32E #(
		.INIT(32'hCCCCCCCC) // Initial Value of Shift Register
		) L1A (
		.Q(b[i]), // SRL data output
		.Q31(scan_chain[i+1]), // SRL cascade output pin
		.A(A[(i*5+4):(i*5)]), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
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
		.INIT(32'hAAAAAAAA) // Initial Value of Shift Register
		) L2A (
		.Q(c[i]), // SRL data output
		.Q31(scan_chain[lay1+i+1]), // SRL cascade output pin
		.A(b[(i*5+4):(i*5)]), // 5-bit shift depth select input
		.CE(CE), // Clock enable input
		.CLK(CLK), // Clock input
		.D(scan_chain[lay1+i]) // SRL data input
		);
		// End of SRLC32E_inst instantiation
	 end
endgenerate

//final layer
SRLC32E #(
.INIT(32'hAAAAAAAA) // Initial Value of Shift Register
) W (
.Q(Z), // SRL data output
.Q31(Q), // SRL cascade output pin
.A(c), // 5-bit shift depth select input
.CE(CE), // Clock enable input
.CLK(CLK), // Clock input
.D(scan_chain[lay1+lay2]) // SRL data input
);
// End of SRLC32E_inst instantiation

endmodule