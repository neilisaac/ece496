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
	if (buffer == 0)
		buffer <= in;
	else begin
		buffer[7:1] <= buffer[6:0];
		buffer[0] <= buffer[7];
	end
end

assign out = buffer;

endmodule
