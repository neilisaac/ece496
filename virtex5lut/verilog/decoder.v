module decoder (
	input			clock,			// main design clock
	input			reset,			// main reset signal
	input			ready,			// set high when uart is ready for input
	input			in_valid,		// set high when uart output is ready
	output			out_valid,		// must set this once uart is ready and data is ready to send
	input [7:0]		in_data,		// input data from uart
	output [7:0]	out_data,		// output data to uart
	output			shift_head,		// beginning of the shift chain (comes from uart)
	input			shift_tail,		// end of the shift chain (returns to the uart)
	output reg		shift_enable	// signal to do a shift
);

parameter BLE_SIZE = 65;
parameter BLE_BYTES = 3;



// every time a new byte arrives, we shift it into the padding_buffer

reg read_shift;
reg [4:0] shift_count;

always @ (posedge clock or posedge reset) begin
	if (reset) begin
		read_shift <= 0;
		shift_count <= 0;
	end

	else if (in_valid && shift_count < 8) begin
		read_shift <= 1;
		shift_count <= 0;
	end

	else if (read_shift)
		shift_count <= shift_count + 1;
end



// once all bytes have arrived for a BLE, we raise shift_enable to program it

reg [8:0] byte_count; // must be large enough for max bytes plus one
reg [BLE_SIZE:0] bit_count;

always @ (posedge clock or posedge reset) begin
	if (reset) begin
		byte_count <= 0;
		bit_count <= 0;
	end

	else if (byte_count == BLE_BYTES) begin
		byte_count <= 0;
		bit_count <= 1;
		shift_enable <= 1;
	end

	else if (bit_count == BLE_SIZE)
		shift_enable <= 0;

	else if (shift_enable)
		bit_count <= bit_count + 1;

	else if (read_shift == 1 && shift_count == 0)
		byte_count <= byte_count + 1;
end


// read_buffer holds 8 bits last read from uart

reg [7:0] read_buffer;

always @ (posedge clock or posedge reset)
	if (reset)
		read_buffer <= 0;
	else if (in_valid)
		read_buffer <= in_data;
	else if (read_shift)
		read_buffer <= read_buffer << 1;



// padding_buffer holds previous bytes

reg [BLE_SIZE-1:8] padding_buffer;

always @ (posedge clock or posedge reset)
	if (reset)
		padding_buffer <= 0;
	else if (read_shift || shift_enable)
		padding_buffer <= padding_buffer << 1;



// NOT YET IMPLEMENTED

wire verify_shift = 0;
assign out_data = 0;
assign out_valid = 0;



// shift_head is attached to either the end of the padding buffer or it
// loops back from the shift_tail when we're verifying (so the data isn't lost)

assign shift_head = verify_shift ? shift_tail : padding_buffer[BLE_SIZE-1];



endmodule

