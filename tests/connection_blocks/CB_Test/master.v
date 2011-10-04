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

wire [4:0] cb1;
wire [4:0] cb2;
wire lb1;
wire lb2;

wire [4:0] cb3;
wire [4:0] cb4;
wire [5:0] lb3;
wire [5:0] lb4;

ConnectionBlock CB_inst (
	.LB1_IN(lb1),
	.LB2_IN(lb2),
	.CB1_IN(cb1),
	.CB2_IN(cb2),
	.LB1_OUT(lb3),
	.LB2_OUT(lb4),
	.CB1_OUT(cb3),
	.CB2_OUT(cb4),
	.CLK(SYSCLK),
	.CE(PUSH_N),
	.SIN(PUSH_S),
	.SOUT(LEDS[0])
);




//assign LEDS = { 4'b0, ble_out };
assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };
assign UART_TX = 0;


endmodule