`include "parameters.v"

module master (
	input clock_pin,
	input [4:0] button_pins,
	input [7:0] switch_pins,
	input uart_in_pin,
	output uart_out_pin,
	output [7:0] led_pins
);



wire programming_clock = clock_pin;
wire programming_reset = reset_pin;
wire user_reset = button_pins[0];
wire user_clock = button_pins[1];



wire uart_in_valid;
wire uart_in_ready;
wire uart_out_valid;
wire [7:0] uart_in_data;
wire [7:0] uart_out_data;
wire uart_active;

uart uart_inst (
	.main_clk(programming_clock),
	.reset(programming_reset),
	.rx(uart_in_pin),
	.tx(uart_out_pin),
	.in_ready(uart_in_ready),
	.in_valid(uart_in_valid),
	.out_valid(uart_out_valid),
	.in_data(uart_in_data),
	.out_data(uart_out_data),
	.active(uart_active),
);



wire shift_head;
wire shift_tail;
wire shift_enable;

decoder decoder_inst (
	.clock(programming_clock),
	.reset(programming_reset),
	.ready(uart_in_ready),
	.in_valid(uart_out_valid),
	.out_valid(uart_in_valid),
	.in_data(uart_out_data),
	.out_data(uart_in_data),
	.shift_head(shift_head),
	.shift_tail(shift_tail),
	.shfit_enable(shift_enable)
);



overlay overlay_inst (
	.clock(user_clock),
	.reset(user_reset),
	.io_in(switch_pins[lut_size-1:0]),
	.io_out(led_pins[0]),
	.shift_in(shift_head),
	.shift_out(shift_tail),
	.shift_enable(shift_enable)
);


assign led_pins[7:1] = 0;


endmodule

