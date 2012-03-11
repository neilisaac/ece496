module test(
	clk,
	in,
	out
);

input clk;
input  [7:0] in;
output [7:0] out;

reg [7:0] buffer;

always @ (posedge clk) begin
	buffer <= buffer + in;
end

assign out = buffer;

endmodule
