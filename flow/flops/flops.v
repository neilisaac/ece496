module test(
	in,
	out,
	clk
);

input clk;
input  [6:0] in;
output [7:0] out;

always @(posedge clk)
	out[6:0] <= in;

assign out[7] = 0;

endmodule
