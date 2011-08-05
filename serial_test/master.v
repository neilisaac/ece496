module master (
	input SYSCLK,
	input SYSRST,
	input PUSH_N, PUSH_S, PUSH_E, PUSH_W, PUSH_C,
	input [7:0] DIP,
	input UART_RX,
	output UART_TX,
	output LED_N, LED_S, LED_E, LED_W, LED_C,
	output [7:0] LEDS
);


wire uart_rx_valid;
wire uart_tx_ready;
wire uart_tx_valid;
wire [7:0] uart_rx_data;
wire [7:0] uart_tx_data;
wire uart_active;

UART UART_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.RX(UART_RX),
	.RX_VALID(uart_rx_valid),
	.RX_DATA(uart_rx_data),
	.TX(UART_TX),
	.TX_READY(uart_tx_ready),
	.TX_VALID(uart_tx_valid),
	.TX_DATA(uart_tx_data)
);


wire shift_head;
wire shift_tail;
wire shift_enable;

DECODER decoder_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.UART_READY(uart_tx_ready),
	.RX_VALID(uart_rx_valid),
	.TX_VALID(uart_tx_valid),
	.RX_DATA(uart_rx_data),
	.TX_DATA(uart_tx_data),
	.SHIFT_HEAD(shift_head),
	.SHIFT_TAIL(shift_tail),
	.SHIFT_ENABLE(shift_enable)
);


wire user_clock;
wire user_reset;
wire ble_out;

transition user_clock_tran_inst(SYSCLK, ~SYSRST, PUSH_E, user_clock);
transition user_reset_tran_inst(SYSCLK, ~SYSRST, PUSH_N, user_reset);

BLE ble_inst (
	.PCLK(SYSCLK),
	.PRST(~SYSRST),
	.UCLK(user_clock),
	.URST(user_reset),
	.A(DIP[5:0]),
	.SIN(shift_head),
	.SOUT(shift_tail),
	.SE(shift_enable),
	.F(ble_out)
);


reg [7:0] last_uart_byte;
always @ (posedge SYSCLK)
	if (uart_rx_valid)
		last_uart_byte <= uart_rx_data;

reg [7:0] shift_counter;
always @ (posedge SYSCLK)
	if (user_reset)
		shift_counter <= 0;
	else if (uart_rx_valid)
		shift_counter <= shift_counter + 1;


assign LED_S = ble_out;
assign { LED_N, LED_C, LED_E, LED_W } = 4'b0;
assign LEDS = shift_counter;


endmodule

