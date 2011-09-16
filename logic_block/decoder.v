// Read bytes from the UART.
// Controls the shift signals to the rest of the circuit.

module DECODER (
	input			SCLK,			// main design clock
	input			RESET,			// main reset signal
	input			RX_VALID,		// set high when uart output is ready
	input			UART_READY,		// set high when uart is ready to receive data
	output			TX_VALID,		// indicate that there's data to send 
	input [7:0]		RX_DATA,		// input data from uart
	output [7:0]	TX_DATA,		// output data to uart
	output			SHIFT_HEAD,		// beginning of the shift chain
	input			SHIFT_TAIL,		// end of the shift chain
	output			SHIFT_ENABLE	// signal to do a shift
);


reg shifting_head;
reg [3:0] head_shift_count;
reg [7:0] head_reg;

always @ (posedge SCLK) begin
	if (RESET) begin
		shifting_head <= 0;
		head_shift_count <= 0;
		head_reg <= 0;
	end

	else if (head_shift_count == 7) begin
		shifting_head <= 0;
	end

	else if (shifting_head) begin
		head_shift_count <= head_shift_count + 1;
		head_reg <= head_reg << 1;
	end

	else if (RX_VALID) begin
		shifting_head <= 1;
		head_shift_count <= 0;
		head_reg <= RX_DATA;
	end
end


assign SHIFT_HEAD = head_reg[7];
assign SHIFT_ENABLE = shifting_head;

// echo bytes back to the sender
assign TX_DATA = RX_DATA;
assign TX_VALID = RX_VALID;


endmodule

