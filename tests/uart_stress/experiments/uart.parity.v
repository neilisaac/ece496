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


wire even_parity = 1;


reg sync;
reg [9:0] clk_count;

always @ (posedge SCLK) begin
	if (clk_count == 868 || sync)
		clk_count <= 0;
	else
		clk_count <= clk_count + 1;
end

wire uart_clk = (clk_count == 434);


reg read, discard, parity;
reg [3:0] read_count;

wire parity_expect = RX_DATA[0] ^ RX_DATA[1] ^ RX_DATA[2] ^
	RX_DATA[3] ^ RX_DATA[4] ^ RX_DATA[5] ^ RX_DATA[6] ^ RX_DATA[7];

always @ (posedge SCLK) begin
	RX_VALID <= 0;
	sync <= 0;

	if (RESET) begin
		read <= 0;
		discard <= 0;
		read_count <= 0;
		parity <= 0;
		RX_DATA <= 0;
	end

	else if (uart_clk & read) begin
		parity <= RX;

		if (read_count == 9 && ~even_parity) begin
			RX_VALID <= ~discard & RX;
			read <= 0;
		end

		else if (read_count == 10) begin
			RX_VALID <= ~discard & (parity == parity_expect) & RX;
			read <= 0;
		end
		
		else begin
			RX_DATA <= { RX, RX_DATA[7:1] };
			read_count <= read_count + 1;
		end
	end

	else if (read && read_count == 0 && RX) begin
		discard <= 1;
	end

	else if (~read & ~RX) begin
		sync <= 1;
		read <= 1;
		discard <= 0;
		read_count <= 0;
	end
end


reg write, write_parity;
reg [3:0] write_count;
reg [7:0] write_buffer;

always @ (posedge SCLK) begin
	TX <= 1;

	if (RESET) begin
		write <= 0;
		write_count <= 0;
		write_buffer <= 0;
		write_parity <= 0;
	end

	else if (uart_clk & write) begin
		TX <= write_buffer[0];
		write_buffer <= write_buffer >> 1;
		write_count <= write_count + 1;
		write_parity <= write_parity ^ write_buffer[0];

		if (even_parity && write_count == 9)
			TX <= write_parity;
		
		if (write_count == (even_parity ? 10 : 9))
			write <= 0;
	end

	else if (TX_READY & TX_VALID) begin
		write <= 1;
		write_count <= 0;
		write_buffer <= TX_DATA;
		write_parity <= 0;
		TX <= 0;
	end
end

assign TX_READY = ~write;


endmodule

