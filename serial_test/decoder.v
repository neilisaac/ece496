// Read bytes from the UART.
// Controls the shift signals to the rest of the circuit.

module decoder (
	input			CLK,			// main design clock
	input			RST,			// main reset signal
	input			IN_VALID,		// set high when uart output is ready
	input			UART_READY,		// set high when uart is ready to receive data
	output			OUT_VALID,		// must set this once uart is ready and data is ready to send
	input [7:0]		IN_DATA,		// input data from uart
	output [7:0]	OUT_DATA,		// output data to uart
	output			SHIFT_HEAD,		// beginning of the shift chain (comes from uart)
	input			SHIFT_TAIL,		// end of the shift chain (returns to the uart)
	output			SHIFT_ENABLE	// signal to do a shift
);


reg shifting_head;
reg [2:0] head_shift_count;
reg [7:0] head_reg;

always @ (posedge CLK or posedge RST) begin
	if (RST) begin
		shifting_head <= 0;
		head_shift_count <= 0;
		head_reg <= 0;
	end
	else if (IN_VALID) begin
		shifting_head <= 1;
		head_shift_count <= 0;
		head_reg <= IN_DATA;
	end
	else if (head_shift_count == 7) begin
		shifting_head <= 0;
	end
	else if (shifting_head) begin
		head_shift_count <= head_shift_count + 1;
		head_reg <= head_reg << 1;
	end
end


assign SHIFT_HEAD = head_reg[7];
assign SHIFT_ENABLE = shifting_head;
assign OUT_DATA = 8'b0;
assign OUT_VALID = 1'b0;


endmodule

