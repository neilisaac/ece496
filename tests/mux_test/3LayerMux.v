module LayerMux3(input SYSCLK, input PUSH_C, input [7:0] DIP, output [7:7] LEDS);

parameter N = 125;

//Making a 3-layer mux with 5 LUTs:
//(N/5+(N%5 == 0 ? 0 : 1)) = # of LUTs in first layer
//(N/5-(N%5 == 0 ? 1 : 0)) = # of LUTs in first layer -1
//((N/5+(N%5 == 0 ? 0 : 1))/5+((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 0 : 1)) = # of LUTs in second layer
//((N/5+(N%5 == 0 ? 0 : 1))/5-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 1 : 0)) = # of LUTs in second layer -1

wire [N-1:0] A;
wire Z;

wire [(N/5-(N%5 == 0 ? 1 : 0)):0] b; //output bus from layer 1
wire [((N/5+(N%5 == 0 ? 0 : 1))/5-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 1 : 0)):0] c; //output bus from layer 2
wire [N/5+(N%5 == 0 ? 0 : 1)+(N/5+(N%5 == 0 ? 0 : 1))/5+((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 0 : 1)+1:0] scan_chain;

assign A[7:0] = DIP[7:0];
assign A[N-1:8] = 117'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

genvar i;

//generate first layer: ceil(N/5)-1 LUTs
generate
	 for (i=0; i<(N/5-(N%5 == 0 ? 1 : 0)); i=i+1) begin : SR321
		SRLC32E #(
		.INIT(32'h80000000) // Initial Value of Shift Register
		) L1A (
		b[i], // SRL data output
		scan_chain[i+1], // SRL cascade output pin
		A[(i*5+4):(i*5)], // 5-bit shift depth select input
		PUSH_C, // Clock enable input
		SYSCLK, // Clock input
		scan_chain[i] // SRL data input
		);
		// End of SRLC32E_inst instantiation
	 end
endgenerate

// instantiate last LUT of first layer separately to handle possible blanks
SRLC32E #(
.INIT(32'h80000000) // Initial Value of Shift Register
) L1L (
b[N/5-(N%5 == 0 ? 1 : 0)], // SRL data output
scan_chain[N/5+(N%5 == 0 ? 0 : 1)], // SRL cascade output pin
A[(N-1):(N-(N%5 == 0 ? 5: N%5))], // 5-bit shift depth select input
PUSH_C, // Clock enable input
SYSCLK, // Clock input
scan_chain[N/5-(N%5 == 0 ? 1 : 0)] // SRL data input
);

//generate second layer: ceil(ceil(N/5)/5)-1 LUTs
generate
	 for (i=0; i<((N/5+(N%5 == 0 ? 0 : 1))/5-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 1 : 0)); i=i+1) begin : SR322
		SRLC32E #(
		.INIT(32'h80000000) // Initial Value of Shift Register
		) L2A (
		c[i], // SRL data output
		scan_chain[N/5+(N%5 == 0 ? 0 : 1)+i+1], // SRL cascade output pin
		b[(i*5+4):(i*5)], // 5-bit shift depth select input
		PUSH_C, // Clock enable input
		SYSCLK, // Clock input
		scan_chain[N/5+(N%5 == 0 ? 0 : 1)+i] // SRL data input
		);
		// End of SRLC32E_inst instantiation
	 end
endgenerate

// instantiate last LUT of second layer separately to handle possible blanks
SRLC32E #(
.INIT(32'h80000000) // Initial Value of Shift Register
) L2L (
c[(N/5+(N%5 == 0 ? 0 : 1))/5-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 1 : 0)], // SRL data output
scan_chain[N/5+(N%5 == 0 ? 0 : 1)+(N/5+(N%5 == 0 ? 0 : 1))/5+((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 0 : 1)], // SRL cascade output pin
b[(N/5-(N%5 == 0 ? 1 : 0)):((N/5+(N%5 == 0 ? 0 : 1))-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 5: (N/5+(N%5 == 0 ? 0 : 1))%5))], // 5-bit shift depth select input
PUSH_C, // Clock enable input
SYSCLK, // Clock input
scan_chain[N/5+(N%5 == 0 ? 0 : 1)+(N/5+(N%5 == 0 ? 0 : 1))/5-((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 1 : 0)] // SRL data input
);

SRLC32E #(
.INIT(32'h80000000) // Initial Value of Shift Register
) W (
Z, // SRL data output
scan_chain[N/5+(N%5 == 0 ? 0 : 1)+(N/5+(N%5 == 0 ? 0 : 1))/5+((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 0 : 1)+1], // SRL cascade output pin
c, // 5-bit shift depth select input
PUSH_C, // Clock enable input
SYSCLK, // Clock input
scan_chain[N/5+(N%5 == 0 ? 0 : 1)+(N/5+(N%5 == 0 ? 0 : 1))/5+((N/5+(N%5 == 0 ? 0 : 1))%5 == 0 ? 0 : 1)] // SRL data input
);
// End of SRLC32E_inst instantiation

assign LEDS[7] = Z;

endmodule