module test(
	a, b, c,
	x, y, z,
	clk
);

input a, b, c;
input clk;
output x, y, z;

assign x = a & b;
assign y = a | b;

always @ (posedge clk)
	z <= c;

endmodule
