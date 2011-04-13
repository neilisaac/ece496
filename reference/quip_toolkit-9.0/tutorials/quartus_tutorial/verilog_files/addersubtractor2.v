// Top-level module
module addersubtractor2 (A, B, Clock, Reset, Sel, AddSub, Z, Overflow);
	parameter n = 16;
	input [n-1:0] A, B;
	input Clock, Reset, Sel, AddSub;
	output [n-1:0] Z;
	output Overflow;
	reg SelR, AddSubR, Overflow;
	reg [n-1:0] Areg, Breg, Zreg;
	wire [n-1:0] G, M, Z;
	wire over_flow;
	
// Define combinational logic circuit	
	mux2to1 multiplexer (Areg, Z, SelR, G);
		defparam multiplexer.k = n;
	megaddsub nbit_adder (~AddSubR, G, Breg, M, over_flow);
	assign Z = Zreg;

// Define flip-flops and registers	
	always @(posedge Reset or posedge Clock)
	begin
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

