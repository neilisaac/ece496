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

parameter W = 2; //width of interconnecting bus (one way)
parameter O = 4; //width of input into logic blocks (per side)
parameter P = 1; //width of output from logic blocks (per side)

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


wire [P-1:0] lb1in;
wire [P-1:0] lb2in;
wire [W-1:0] cb1in;
wire [W-1:0] cb2in;
wire [O-1:0] lb1out;
wire [O-1:0] lb2out;
wire [W-1:0] cb1out;
wire [W-1:0] cb2out;

assign lb1in = DIP[4];
assign lb2in = DIP[5];
assign cb1in = DIP[1:0];
assign cb2in = DIP[3:2];

ConnectionBlock #(.W(W), .O(O), .P(P)) cb_inst (
	.LB1_IN	(lb1in),
	.LB2_IN	(lb2in),
	.CB1_IN	(cb1in),
	.CB2_IN	(cb2in),
	.LB1_OUT	(lb1out),
	.LB2_OUT	(lb2out),
	.CB1_OUT	(cb1out),
	.CB2_OUT	(cb2out),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(shift_head),
	.SOUT	(shift_tail)
);

assign LEDS[1:0] = cb1out;
assign LEDS[3:2] = cb2out;
assign LEDS[7:4] = lb1out;

assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

