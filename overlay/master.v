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
wire uart_tx_ready;
wire uart_tx_valid;
wire [7:0] uart_rx_data;
wire [7:0] uart_tx_data;

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

TRANSITION user_clock_tran_inst(SYSCLK, ~SYSRST, PUSH_N, user_clock);
TRANSITION user_reset_tran_inst(SYSCLK, ~SYSRST, PUSH_C, user_reset);

parameter NUM_LB_IN = 16;
parameter NUM_LB_OUT = 4;
parameter BUS_WIDTH = 2;

parameter ROWS = 2;
parameter COLS = 2;
parameter IO_PER_CB = 1;

OVERLAY # (
	.NUM_LB_IN		(NUM_LB_IN),
	.NUM_LB_OUT		(NUM_LB_OUT),
	.BUS_WIDTH		(BUS_WIDTH),
	.ROWS			(ROWS),
	.COLS			(COLS),
	.IO_PER_CB		(IO_PER_CB)
) overlay_inst (
	.PCLK			(SYSCLK),
	.PRST			(~SYSRST),
	.UCLK			(user_clock),
	.URST			(user_reset),
	.SE				(shift_enable),
	.SIN			(shift_head),
	.SOUT			(shift_tail),
	.INPUTS			(DIP[7:0]),
	.OUTPUTS		(LEDS[7:0])
);


assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

