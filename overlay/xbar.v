module XBAR(A, SE, CLK, SIN, Z, SOUT);

parameter N = 5;

input [N-1:0] A;
input SE;
input CLK;
input SIN;
output Z;
output SOUT;


generate
	if (N < 6) begin : XBARLAY1
		SRLC32E #( .INIT(32'h00000000) ) xbar1_inst (
			.A(A),
			.CE(SE),
			.CLK(CLK),
			.D(SIN),
			.Q(Z),
			.Q31(SOUT)
		);
	end
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

