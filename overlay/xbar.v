module XBAR(A, SE, CLK, SIN, Z, SOUT);

parameter N = 5;

input [N-1:0] A;
input SE;
input CLK;
input SIN;
output Z;
output SOUT;


generate
	// use 1 shift register to implement an N:1 mux for (1 <= N <= 5)
	if (N < 6) begin : XBARLAY1
		SHIFTREG32 xbar1_inst (
			.A(A),
			.CE(SE),
			.CLK(CLK),
			.D(SIN),
			.Q(Z),
			.Q31(SOUT)
		);
	end

	// for (6 <= N <= 25) we use 2 layers of shift register multiplexers
	else if (N < 26) begin : XBARLAY2
		XBAR2LAYER # (.N(N)) xbar2_inst (
			.A(A),
			.SE(SE),
			.CLK(CLK),
			.SIN(SIN),
			.Z(Z),
			.SOUT(SOUT)
		);
	end

	// for (26 <= N <= 125) we need 3 layers
	else begin : XBARLAY3
		XBAR3LAYER # (.N(N)) xbar3_inst (
			.A(A),
			.SE(SE),
			.CLK(CLK),
			.SIN(SIN),
			.Z(Z),
			.SOUT(SOUT)
		);
	end
endgenerate


endmodule

