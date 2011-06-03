module fitness (
	input clock_pin,
	input [4:0] button_pins,
	input uart_in_pin,
	output uart_out_pin,
	output [7:0] led_pins
);

wire clock = clock_pin;
wire reset = button_pins[1];



// tester

reg test_start;
wire test_done, test_unused, test_select, test_in, test_out;
wire [31:0] test_score;

tester test (
	.clock(clock),
	.reset(reset),
	.start(test_start),
	.test_out(test_out),
	.test_in(test_in),
	.done(test_done),
	.score(test_score),
	.select(test_select),
	.unused(test_unused)
);



// overlap "fpga" design

parameter fpga_width = 10;
parameter fpga_height = 10;

wire fpga_shift_enable, fpga_shift_in, fpga_shift_out;

assign fpga_shift_enable = 0;
assign fpga_shift_in = 0;

wire [fpga_width-1:0] fpga_left_in, fpga_right_in, fpga_left_out, fpga_right_out;
wire [fpga_height-1:0] fpga_bottom_in, fpga_top_in, fpga_bottom_out, fpga_top_out;

assign fpga_left_in = { test_in, 9'b0 };
assign fpga_right_in = 10'b0;
assign fpga_bottom_in = 10'b0;
assign fpga_top_in = 10'b0;
assign test_out = fpga_top_out[5];

overlay # (fpga_width, fpga_height) fpga (
	.clock(clock),
	.reset(reset),
	.shift_enable(fpga_shift_enable),
	.shift_in(fpga_shift_in),
	.shift_out(fpga_shift_out),
	.left_in(fpga_left_in),
	.left_out(fpga_left_out),
	.right_in(fpga_right_in),
	.right_out(fpga_right_out),
	.bottom_in(fpga_bottom_in),
	.bottom_out(fpga_bottom_out),
	.top_in(fpga_top_in),
	.top_out(fpga_top_out)
);



// serial port controller

wire uart_read, uart_active, uart_ready;
wire [7:0] uart_out;

reg uart_write;
reg [7:0] uart_in;

uart serial (
	.main_clk(clock),
	.rx(uart_in_pin),
	.tx(uart_out_pin),
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

assign led_pins[7] = test_unused;
assign led_pins[6] = uart_active;
assign led_pins[5] = uart_ready;
assign led_pins[4] = running;
assign led_pins[3] = test_select;
assign led_pins[2] = complete;
assign led_pins[1] = test_done;
assign led_pins[0] = return_select;



endmodule

