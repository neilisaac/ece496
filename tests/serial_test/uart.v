module UART (
	input SCLK,
	input RESET,
	input RX,
	input TX_VALID,
	input [7:0] TX_DATA,
	output reg RX_VALID,
	output reg [7:0] RX_DATA,
	output reg TX,
	output TX_READY
);


reg uart_clk, sync;
reg [9:0] clk_count;

always @ (posedge SCLK) begin
	uart_clk <= (clk_count == 867);

	if (clk_count == 868)
		clk_count <= 0;
	else
		clk_count <= clk_count + 1;
end


reg read;
reg [3:0] read_count;

always @ (posedge SCLK) begin
	RX_VALID <= 0;

	if (RESET) begin
		read <= 0;
		read_count <= 0;
		RX_DATA <= 0;
	end

	else begin
		if (uart_clk & read) begin
			read_count <= read_count + 1;
			RX_DATA[6:0] <= RX_DATA[7:1];
			RX_DATA[7] <= RX;

			if (read_count == 7) begin
				RX_VALID <= 1;
				read <= 0;
			end
		end

		else if (uart_clk & ~read & ~RX) begin
			read <= 1;
			read_count <= 0;
		end
	end
end


reg write;
reg [3:0] write_count;
reg [7:0] write_buffer;

always @ (posedge SCLK) begin

	if (RESET) begin
		write <= 0;
		write_count <= 0;
		write_buffer <= 0;
		TX <= 1;
	end

	else if (uart_clk & write) begin
		TX <= write_buffer[0];
		write_buffer <= write_buffer >> 1;
		write_count <= write_count + 1;

		if (write_count == 8) begin
			write <= 0;
			TX <= 1;
		end
	end

	else if (TX_READY & TX_VALID) begin
		write <= 1;
		write_count <= 0;
		write_buffer <= TX_DATA;
		TX <= 0;
	end
end

assign TX_READY = ~write;


endmodule

