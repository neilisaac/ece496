`include "params.v"

// abstraction of a 32-bit shift register
module SHIFTREG32 (Q, Q31, A, CE, CLK, D);
	
	input [4:0] A; // address line
	input CLK;     // shift clock
	input CE;      // shift enable
	input D;       // shift input (to LSB)

	output Q;   // output selected by A
	output Q31; // shift out from last bit (MSB)

`ifdef USE_SRLC32E
	
	// implement 32 bit shift register with SRLC32E on Virtex-5+

	SRLC32E # (
		.INIT(32'h00000000)
	) srl32_inst (
		.Q(Q),
		.Q31(Q31),
		.A(A),
		.CE(CE),
		.CLK(CLK),
		.D(D)
	);

`else

	// emulate SRLC32E with behavioural version

	reg [31:0] bits; // shift register bits

	// shift up on CE
	always @ (posedge CLK)
		if (CE)
			bits <= { bits[31:1], D };

	assign Q = bits[A];
	assign Q31 = bits[31];

`endif

endmodule
