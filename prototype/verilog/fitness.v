module fitness (
	input CLOCK_50,
	input UART_RXD,
	input [3:0] KEY,
	input [9:0] SW,

	output UART_TXD,
	output [7:0] LEDG,
	output [9:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3
);

wire clock = CLOCK_50;
wire reset = SW[9];



// tester

reg test_start;
wire test_done, test_unused, test_select;
wire [31:0] test_score;

tester test (
	.clock(clock),
	.reset(reset),
	.start(test_start),
	.done(test_done),
	.score(test_score),
	.select(test_select),
	.unused(test_unused)
);



// serial port controller

wire uart_read, uart_active, uart_ready;
wire [7:0] uart_out;

reg uart_write;
reg [7:0] uart_in;

uart serial (
	.main_clk(clock),
	.rx(UART_RXD),
	.tx(UART_TXD),
	.reset(reset),
	.out_valid(uart_read),
	.out_data(uart_out),
	.in_ready(uart_ready),
	.in_valid(uart_write),
	.in_data(uart_in),
	.active(uart_active)
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



// outputs

assign LEDR[9] = test_unused;
assign LEDR[8] = uart_active;
assign LEDR[7] = uart_ready;
assign LEDR[6:4] = 0;
assign LEDR[3] = running;
assign LEDR[2] = test_select;
assign LEDR[1] = complete;
assign LEDR[0] = test_done;

assign LEDG[7:3] = 0;
assign LEDG[2:0] = return_select;

// 7-segment displays
hex_digits display3 (1, test_score[23:20], HEX3);
hex_digits display2 (1, test_score[19:16], HEX2);
hex_digits display1 (1, test_score[15:12], HEX1);
hex_digits display0 (1, test_score[11:8], HEX0);



endmodule

