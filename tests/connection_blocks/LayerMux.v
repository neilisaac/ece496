module LayerMux(A, CE, CLK, SIN, Z, SOUT);

parameter N = 5;

input [N-1:0] A;
input CE;
input CLK;
input SIN;
output Z;
output SOUT;

generate
	if (N<6) begin: LB1OUTLay1
		SRLC32E #( .INIT(32'h00000000) ) OUTNMux_inst (
			.A(A),
			.CE(CE),
			.CLK(CLK),
			.D(SIN),
			.Q(Z),
			.Q31(SOUT)
		);
	end
	else if (N<26) begin: LB1OUTLay2
		LayerMux2 # (.N(N)) LB1OUTMux_inst (
			.A(A),
			.CE(CE),
			.CLK(CLK),
			.SIN(SIN),
			.Z(Z),
			.SOUT(SOUT)
		);
	end
	else begin: LB1OUTLay3
		LayerMux3 # (.N(N)) LB1OUTMux_inst (
			.A(A),
			.CE(CE),
			.CLK(CLK),
			.SIN(SIN),
			.Z(Z),
			.SOUT(SOUT)
		);
	end
endgenerate


endmodule

