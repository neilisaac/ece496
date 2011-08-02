/// Delay counter module.

module delay (
	input clk_in,
	input reset,
	output clk_out
);

parameter period = 5000000; // 20Hz by default
parameter width = 23;

reg [width-1:0] counter;

always @(posedge clk_in or posedge reset)
	if (reset) counter <= 0;
	else if (counter >= period) counter <= 0;
	else counter <= counter + 1;

assign clk_out = (counter == period - 1);

endmodule

