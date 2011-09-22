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
reg uart_tx_valid;
wire [7:0] uart_rx_data;

uart UART_inst (
	.clk(SYSCLK),
	.rst(~SYSRST),
	.rx(UART_RX),
	.received(uart_rx_valid),
	.rx_byte(uart_rx_data),
	.tx(UART_TX),
	.is_transmitting(uart_tx_busy),
	.transmit(uart_tx_valid),
	.tx_byte(uart_rx_data)
);

reg [7:0] good, total;

always @ (posedge SYSCLK) begin
	uart_tx_valid <= 0;

	if (PUSH_C) begin
		good <= 0;
		total <= 0;
		uart_tx_valid <= 0;
	end
	else begin
		if (uart_rx_valid) begin
			total <= total + 1;

			if (uart_rx_data == total)
				good <= good + 1;

			if (~uart_tx_busy)
				uart_tx_valid <= 1;
		end
	end
end


assign LEDS = PUSH_S ? total : good;
assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

