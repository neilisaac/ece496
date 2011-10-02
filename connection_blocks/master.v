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

parameter W = 2;

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
wire [W-1:0] sbin_n;
wire [W-1:0] sbin_e;
wire [W-1:0] sbin_s;
wire [W-1:0] sbin_w;
wire [W-1:0] sbout_n;
wire [W-1:0] sbout_e;
wire [W-1:0] sbout_s;
wire [W-1:0] sbout_w;

assign sbin_n = DIP[1:0];
assign sbin_e = DIP[3:2] ;
assign sbin_s = DIP[5:4];
assign sbin_w = DIP[7:6];

TRANSITION user_clock_tran_inst(SYSCLK, ~SYSRST, PUSH_E, user_clock);
TRANSITION user_reset_tran_inst(SYSCLK, ~SYSRST, PUSH_N, user_reset);

SwitchBlock #(.W(W)) sb_inst (
	.IN_N	(sbin_n),
	.IN_E	(sbin_e),
	.IN_S	(sbin_s),
	.IN_W	(sbin_w),
	.OUT_N	(sbout_n),
	.OUT_E	(sbout_e),
	.OUT_S	(sbout_s),
	.OUT_W	(sbout_w),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(shift_head),
	.SOUT	(shift_tail)
);

reg [7:0] test;
always @ (posedge SYSCLK) if (shift_enable) test <= { shift_head, test[7:1] };
assign LEDS[1:0] = sbout_n;
assign LEDS[3:2] = sbout_e;
assign LEDS[5:4] = sbout_s;
assign LEDS[7:6] = sbout_w;

assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

