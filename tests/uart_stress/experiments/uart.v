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


reg sync;
reg [13:0] clk_count;

always @ (posedge SCLK) begin
	if (clk_count == 10417 || sync)
		clk_count <= 0;
	else
		clk_count <= clk_count + 1;
end

wire uart_clk = (clk_count == 5208);


reg read;
reg [3:0] read_count;

always @ (posedge SCLK) begin
	RX_VALID <= 0;
	sync <= 0;

	if (RESET) begin
		read <= 0;
		read_count <= 0;
		RX_DATA <= 0;
	end

	else if (uart_clk & read) begin
		if (read_count == 9) begin
			RX_VALID <= 1;
			read <= 0;
		end else begin
			RX_DATA <= { RX, RX_DATA[7:1] };
			read_count <= read_count + 1;
		end
	end

	else if (~read & ~RX) begin
		sync <= 1;
		read <= 1;
		read_count <= 0;
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
		write_count <= write_count + 1;

		if (write_count == 0) begin
			TX <= 0;
		end

		else if (write_count >= 9) begin
			TX <= 1;
		end

		else begin
			TX <= write_buffer[0];
			write_buffer <= write_buffer >> 1;
		end

		if (write_count == 10)
			write <= 0;
	end

	else if (TX_READY & TX_VALID) begin
		write <= 1;
		write_count <= 0;
		write_buffer <= TX_DATA;
	end
end

assign TX_READY = ~write;


endmodule

