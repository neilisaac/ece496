`include "parameters.v"

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
	output			shift_enable	// signal to do a shift
);


// coordinate test

reg running, complete;
reg [2:0] return_select;

always @ (posedge clock) begin

	if (reset) begin
		running <= 0;
		complete <= 0;
		return_select <= 0;
	end

	else begin

		// wait for start signal from host
		if (~running & uart_read & uart_out == "S") begin
			running <= 1;
			complete <= 0;
			test_start <= 1;
		end
		else test_start <= 0;

		// wait for test-complete signal from tester
		if (running & test_done) begin
			running <= 0;
			complete <= 1;
			return_select <= 0;
		end

		// return one byte at a time
		if (complete & uart_ready) begin
			uart_write <= 1;
			return_select <= return_select + 1;
		end
		else uart_write <= 0;

		// done
		if (return_select == 5) begin
			complete <= 0;
			return_select <= 0;
		end
	end
end

// select output signal
always @ (return_select, test_score)
	case (return_select)
		1: uart_in = "R";
		2: uart_in = test_score[7:0];
		3: uart_in = test_score[15:8];
		4: uart_in = test_score[23:16];
		5: uart_in = test_score[31:24];
		default: uart_in = 0;
	endcase

endmodule

