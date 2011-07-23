module master (
	input SYSCLK,
	input SYSRST,
	input PUSH_N, PUSH_S, PUSH_E, PUSH_W, PUSH_C,
	input [7:0] DIP,
	input RS232_IN,
	output RS232_OUT,
	output LED_N, LED_S, LED_E, LED_W, LED_C,
	output [7:0] LEDS
);


wire uart_in_valid;
wire uart_in_ready;
wire uart_out_valid;
wire [7:0] uart_in_data;
wire [7:0] uart_out_data;
wire uart_active;

uart uart_inst (
	.MAIN_CLK(SYSCLK),
	.RESET(SYSRST),
	.RX(RS232_IN),
	.TX(RS232_OUT),
	.IN_READY(uart_in_ready),
	.IN_VALID(uart_in_valid),
	.OUT_VALID(uart_out_valid),
	.IN_DATA(uart_in_data),
	.OUT_DATA(uart_out_data),
	.ACTIVE(uart_active)
);


reg [7:0] last_uart_byte;

always @ (posedge SYSCLK)
	if (uart_out_valid)
		last_uart_byte <= uart_out_data;


wire shift_head;
wire shift_tail;
wire shift_enable;

decoder decoder_inst (
	.CLK(SYSCLK),
	.RST(SYSRST),
	.UART_READY(uart_in_ready),
	.IN_VALID(uart_out_valid),
	.OUT_VALID(uart_in_valid),
	.IN_DATA(uart_out_data),
	.OUT_DATA(uart_in_data),
	.SHIFT_HEAD(shift_head),
	.SHIFT_TAIL(shift_tail),
	.SHIFT_ENABLE(shift_enable)
);


wire user_clock;
wire user_reset;
wire ble_out;

transition user_clock_tran_inst(SYSCLK, SYSRST, PUSH_E, user_clock);
transition user_reset_tran_inst(SYSCLK, SYSRST, PUSH_N, user_reset);

ble ble_inst (
	.PCLK(SYSCLK),
	.UCLK(user_clock),
	.A(DIP[4:0]),
	.SIN(shift_head),
	.SOUT(shift_tail),
	.SE(shift_enable),
	.F(ble_out)
);


assign LED_S = ble_out;
assign { LED_N, LED_C, LED_E, LED_W } = 4'b0;
assign LEDS = last_uart_byte;


endmodule

