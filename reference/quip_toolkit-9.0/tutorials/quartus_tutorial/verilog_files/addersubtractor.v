 // (C) 2003 Altera Corporation. All rights reserved. The design examples are 
// being provided on an "as-is" basis and as an accommodation and therefore 
// all warranties, representations or guarantees of any kind (whether express,
// implied or statutory) including, without limitation, warranties of 
// merchantability, non-infringement, or fitness for a particular purpose, 
// are specifically disclaimed.

// Top-level module
module addersubtractor (A, B, Clock, Reset, Sel, AddSub, Z, Overflow);
	parameter n = 16;
	input [n-1:0] A, B;
	input Clock, Reset, Sel, AddSub;
	output [n-1:0] Z;
	output Overflow;
	reg SelR, AddSubR, Overflow;
	reg [n-1:0] Areg, Breg, Zreg;
	wire [n-1:0] G, H, M, Z;
	wire carryout, over_flow;
	
// Define combinational logic circuit	
	assign H = Breg ^ {n{AddSubR}};	
	mux2to1 multiplexer (Areg, Z, SelR, G);
		defparam multiplexer.k = n;
	adderk nbit_adder (AddSubR, G, H, M, carryout);
		defparam nbit_adder.k = n;
	assign over_flow = carryout ^ G[n-1] ^ H[n-1] ^ M[n-1];
	assign Z = Zreg;

// Define flip-flops and registers	
	always @(posedge Reset or posedge Clock)
		if (Reset == 1)
		begin
		   Areg <= 0;  Breg <= 0;  Zreg <= 0;
		   SelR <= 0;  AddSubR <= 0;  Overflow <= 0;
		end
		else
		begin
		   Areg <= A;  Breg <= B;  Zreg <= M;
		   SelR <= Sel;  AddSubR <= AddSub;  Overflow <= over_flow;
		end
endmodule

// k-bit 2-to-1 multiplexer
module mux2to1 (V, W, Sel, F);
	parameter k = 8;
	input [k-1:0] V, W;
	input Sel;
	output [k-1:0] F;
	reg [k-1:0] F;
	
	always @(V or W or Sel)
		if (Sel == 0)
			F = V;
		else
			F = W;
endmodule

// k-bit adder
module adderk (carryin, X, Y, S, carryout);
	parameter k = 8;
	input carryin;
	input [k-1:0] X, Y;
	output [k-1:0] S;
	output carryout;
	reg [k-1:0] S;
	reg carryout;
	
	always @(X or Y or carryin)
		{carryout, S} = X + Y + carryin;
endmodule






		
		

