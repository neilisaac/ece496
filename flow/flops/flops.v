module test(
	in,
	out,
	clk
);

input clk;
input  [7:0] in;
output [7:0] out;

always @(posedge clk)
	out <= in;

endmodule
