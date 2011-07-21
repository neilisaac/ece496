module overlay (
	clock, reset,
	shift_enable, shift_in, shift_out,
	left_in, bottom_in, right_in, top_in,
	left_out, bottom_out, right_out, top_out
);


parameter width = 10;
parameter height = 10;


input clock, reset;

input shift_enable, shift_in;
output shift_out;

input  [height-1:0] left_in,    right_in;
input  [width-1:0]  bottom_in,  top_in;
output [height-1:0] left_out,   right_out;
output [width-1:0]  bottom_out, top_out;


// internal connection wires
reg [height:-1] values [width:-1];
wire [height*height-1:0] outputs;
wire [width*height:0] shift_chain;

// connect scan boundary
assign shift_chain[width*height] = shift_in;
assign shift_out = shift_chain[0];



// assign cell inputs
integer row, col;
always @ (*) begin
	for (row = 0; row < height; row = row+1) begin
		// assign left/right inputs from outside
		values[row][-1] = left_in[row];
		values[row][width] = right_in[row];
		
		// assign outputs from cells
		for (col = 0; col < width; col = col+1)
			values[row][col] = outputs[row*width+col];
	end
	
	for (col = 0; col < width; col = col+1) begin
		// assign top/bottom inputs from outside
		values[-1][col] = bottom_in[col];
		values[height][col] = top_in[col];
	end
	
	// assign unused corner values to GND
	values[-1][-1] = 1'b0;
	values[-1][width] = 1'b0;
	values[height][-1] = 1'b0;
	values[height][width] = 1'b0;
end



// generate cells
genvar i;
generate
	for (i = 0; i < width * height; i = i+1) begin : CELL
		integer row = i / width;
		integer col = i % width;
		
		// instantiate cell
		fpga_cell c (
				.clock(clock),
				.reset(reset),
				.inputs( {
						values[row][col-1],
						values[row-1][col],
						values[row][col+1],
						values[row+1][col]
					} ),
				.value(outputs[i]),
				.shift_enable(shift_enable),
				.shift_in(shift_chain[i]),
				.shift_out(shift_chain[i + 1])
			);
	end
endgenerate


endmodule
