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


wire uart_read;
wire [7:0] uart_data;

UART_IN UART_IN_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.RX(UART_RX),
	.VALID(uart_read),
	.DATA(uart_data)
);


reg sent;
wire uart_ready;
wire send = uart_ready & uart_read & ~sent;

always @ (posedge SYSCLK)
	if (~SYSRST)
		sent <= 0;
	else if (send)
		sent <= 1;
	else if (~uart_read)
		sent <= 0;

UART_OUT UART_OUT_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.VALID(send),
	.DATA(DIP),
	.TX(UART_TX),
	.READY(uart_ready)
);


reg [7:0] uart_byte;

always @ (posedge SYSCLK)
	if (~SYSRST)
		uart_byte <= 0;
	else if (uart_read)
		uart_byte <= uart_data;

assign LEDS = uart_byte;


assign LED_N = PUSH_N;
assign LED_C = PUSH_C;
assign LED_S = PUSH_S;
assign LED_E = PUSH_E;
assign LED_W = PUSH_W;


endmodule

