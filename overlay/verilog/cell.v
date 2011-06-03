module fpga_cell (
	clock, reset,
	inputs, shift_in, shift_enable,
	value, shift_out
);

parameter size = 4;
parameter width = 2 ** size;

input clock, reset;
input [size-1:0] inputs;
input shift_in, shift_enable;
output value;
output shift_out;

reg [width-1:0] func;
wire [width:0] shift_values = { func, shift_in };

integer i;
always @ (posedge clock)
	for (i = 0; i < width; i = i+1)
		if (reset)
			func[i] <= 0;
		else if (shift_enable)
			func[i] <= shift_values[i];

assign shift_out = shift_values[width];

assign value = func[inputs];


endmodule
