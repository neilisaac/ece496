module MASTER (
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
wire uart_tx_busy;
wire uart_tx_valid;
wire [7:0] uart_rx_data;
wire [7:0] uart_tx_data;

UART UART_inst (
	.CLK(SYSCLK),
	.RST(~SYSRST),
	.RX(UART_RX),
	.RECEIVED(uart_rx_valid),
	.RX_BYTE(uart_rx_data),
	.TX(UART_TX),
	.IS_TRANSMITTING(uart_tx_busy),
	.TRANSMIT(uart_tx_valid),
	.TX_BYTE(uart_tx_data)
);


wire shift_head;
wire shift_tail;
wire shift_enable;

DECODER decoder_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.UART_READY(~uart_tx_busy),
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
wire [9:0] ble_in = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, DIP };
wire [3:0] ble_out;

TRANSITION user_clock_tran_inst(SYSCLK, ~SYSRST, PUSH_E, user_clock);
TRANSITION user_reset_tran_inst(SYSCLK, ~SYSRST, PUSH_N, user_reset);

LOGIC_BLOCK lb_inst (
	.PCLK	(SYSCLK),
	.PRST	(~SYSRST),
	.UCLK	(user_clock),
	.URST	(user_reset),
	.IN		(ble_in),
	.SIN	(shift_head),
	.SOUT	(shift_tail),
	.SE		(shift_enable),
	.OUT	(ble_out)
);

assign LEDS = { 4'b0, ble_out };
assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

