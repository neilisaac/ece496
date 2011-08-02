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
	.main_clk(SYSCLK),
	.reset(SYSRST),
	.rx(RS232_IN),
	.tx(RS232_OUT),
	.in_ready(uart_in_ready),
	.in_valid(uart_in_valid),
	.out_valid(uart_out_valid),
	.in_data(uart_in_data),
	.out_data(uart_out_data),
	.active(uart_active)
);

assign uart_in_data = DIP;
assign uart_in_valid = PUSH_N;

assign LED_N = uart_in_ready;
assign LED_C = PUSH_C | uart_active;
assign LED_S = PUSH_S;
assign LED_E = PUSH_E;
assign LED_W = PUSH_W;


reg [7:0] last_uart_byte, uart_count;

always @ (posedge SYSCLK)
	if (uart_out_valid) begin
		last_uart_byte <= uart_out_data;
		uart_count <= uart_count + 1;
	end

assign LEDS = last_uart_byte | uart_count;

endmodule

