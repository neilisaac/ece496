module test(
	in,
	out
);

input  [7:0] in;
output [7:0] out;

assign out = in[7:4] + in[3:0];

endmodule
