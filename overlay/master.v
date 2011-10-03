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


wire [4:0] shift_chain;
assign shift_chain[0] = shift_head;
assign shift_tail = shift_chain[4];

wire [7:0] out, alt;

parameter NUM_LB_IN = 16;
parameter NUM_LB_OUT = 4;
parameter BUS_WIDTH = 2;

TILE # (
	.NUM_LB_IN		(NUM_LB_IN),
	.NUM_LB_OUT		(NUM_LB_OUT),
	.BUS_WIDTH		(BUS_WIDTH)
) tile_inst (
	.PCLK			(SYSCLK),
	.PRST			(~SYSRST),
	.UCLK			(user_clock),
	.URST			(user_reset),
	.SE				(shift_enable),
	.NORTH_LB_IN	(),
	.EAST_LB_IN		(),
	.SOUTH_LB_IN	(),
	.WEST_LB_IN		(),
	.NORTH_LB_OUT	(alt[3:0]),
	.EAST_LB_OUT	(alt[7:4]),
	.SOUTH_LB_OUT	(),
	.WEST_LB_OUT	(),
	.NORTH_BUS_IN	(DIP[1:0]),
	.EAST_BUS_IN	(DIP[3:2]),
	.SOUTH_BUS_IN	(DIP[5:4]),
	.WEST_BUS_IN	(DIP[7:6]),
	.NORTH_BUS_OUT	(out[1:0]),
	.EAST_BUS_OUT	(out[3:2]),
	.SOUTH_BUS_OUT	(out[5:4]),
	.WEST_BUS_OUT	(out[7:6]),
	.CB1_SIN		(shift_chain[0]),
	.CB1_SOUT		(shift_chain[1]),
	.SB_SIN			(shift_chain[1]),
	.SB_SOUT		(shift_chain[2]),
	.CB2_SIN		(shift_chain[2]),
	.CB2_SOUT		(shift_chain[3]),
	.LB_SIN			(shift_chain[3]),
	.LB_SOUT		(shift_chain[4])
);


assign LEDS = PUSH_S ? alt : out;

assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

