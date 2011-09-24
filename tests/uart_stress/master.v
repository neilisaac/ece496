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
wire uart_rx_parity;
wire uart_tx_ready;
reg uart_tx_valid;
wire [7:0] uart_rx_data;

UART UART_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.RX(UART_RX),
	.RX_VALID(uart_rx_valid),
	.RX_DATA(uart_rx_data),
	.RX_PARITY(uart_rx_parity),
	.TX(UART_TX),
	.TX_READY(uart_tx_ready),
	.TX_VALID(uart_tx_valid),
	.TX_DATA(uart_rx_data)
);

reg [7:0] good, total, last;

always @ (posedge SYSCLK) begin
	uart_tx_valid <= 0;

	if (PUSH_C) begin
		good <= 0;
		total <= 0;
		last <= 0;
		uart_tx_valid <= 0;
	end
	else begin
		if (uart_rx_valid) begin
			total <= total + 1;
			last <= uart_rx_data;

			if (uart_rx_data == total)
				good <= good + 1;

			if (uart_tx_ready)
				uart_tx_valid <= 1;
		end
	end
end


assign LEDS = PUSH_S ? total : PUSH_E ? good : last;
assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { uart_rx_parity | PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

