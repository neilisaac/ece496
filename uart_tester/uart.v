module UART_IN (
	input SCLK,
	input RESET,
	input RX,
	output reg VALID,
	output reg [7:0] DATA
);

reg uart_clk, sync;
reg [9:0] clk_count;

always @ (posedge SCLK) begin
	uart_clk <= (clk_count == 434);

	if (sync | clk_count == 868)
		clk_count <= 0;
	else
		clk_count <= clk_count + 1;
end

reg read;
reg [3:0] count;

always @ (posedge SCLK) begin

	VALID <= 0;
	sync <= 0;

	if (RESET) begin
		read <= 0;
		count <= 0;
		DATA <= 0;
	end

	else begin
		if (uart_clk & read) begin
			if (count == 8) begin
				VALID <= 1;
				read <= 0;
			end

			count <= count + 1;
			DATA[6:0] <= DATA[7:1];
			DATA[7] <= RX;
		end

		else if (~read & ~RX) begin
			read <= 1;
			count <= 0;
			//sync <= 1;
		end
	end
end

endmodule


module UART_OUT (
	input SCLK,
	input RESET,
	input VALID,
	input [7:0] DATA,
	output reg TX,
	output READY
);

reg uart_clk;
reg [9:0] clk_count;

always @ (posedge SCLK) begin
	uart_clk <= (clk_count == 434);

	if (clk_count == 868)
		clk_count <= 0;
	else
		clk_count <= clk_count + 1;
end

reg write;
reg [3:0] count;
reg [7:0] buffer;

always @ (posedge SCLK) begin

	if (RESET) begin
		write <= 0;
		count <= 0;
		buffer <= 0;
		TX <= 1;
	end

	else begin
		if (uart_clk & write) begin
			TX <= buffer[0];
			buffer <= buffer >> 1;
			count <= count + 1;

			if (count == 8) begin
				write <= 0;
				TX <= 1;
			end
		end

		else if (READY & VALID) begin
			write <= 1;
			count <= 0;
			buffer <= DATA;
			TX <= 0;
		end
	end
end

assign READY = ~write;

endmodule

