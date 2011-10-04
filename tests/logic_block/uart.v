module UART (
	input SCLK,
	input RESET,
	input RX,
	input TX_VALID,
	input [7:0] TX_DATA,
	output reg RX_VALID,
	output RX_PARITY,
	output reg [7:0] RX_DATA,
	output reg TX,
	output TX_READY
);


parameter FREQ = 100000000;
parameter BAUD = 115200;
parameter COUNT = FREQ / (BAUD * 8);
parameter PARITY = 1;

reg [20:0] clk_count;
wire uart_clk = (clk_count == COUNT - 1);

always @ (posedge SCLK)
	clk_count <= (clk_count == COUNT) ? 0 : clk_count + 1;


reg read_active, read_void, read_parity;
reg [2:0] read_tick, read_phase;
reg [3:0] read_count;

always @ (posedge SCLK) begin
	RX_VALID <= 0;
	read_tick <= read_tick + uart_clk;

	if (RESET) begin
		read_active <= 0;
		read_void <= 0;
		read_count <= 0;
		read_parity <= 0;
		RX_DATA <= 0;
	end

	else if (uart_clk & ~read_active & ~RX) begin
		read_active <= 1;
		read_void <= 0;
		read_count <= 0;
		read_parity <= 0;
		read_phase <= read_tick + 4;
	end

	else if (uart_clk && read_active && read_tick == read_phase) begin
		if (read_count == 0)
			if (RX) read_void <= 1;

		if (PARITY && read_count == 9) begin
			if (RX != read_parity) read_void <= 1;
			read_count <= read_count + 1;
		end else if (read_count == (PARITY ? 10 : 9)) begin
			RX_VALID <= ~read_void & RX;
			read_active <= 0;
		end else begin
			RX_DATA <= { RX, RX_DATA[7:1] };
			read_count <= read_count + 1;
			read_parity <= read_parity ^ RX;
		end
	end
end

assign RX_PARITY = read_parity;


reg write_active, write_parity;
reg [2:0] write_tick;
reg [3:0] write_count;
reg [7:0] write_buffer;

always @ (posedge SCLK) begin
	if (RESET) begin
		write_active <= 0;
		write_count <= 0;
		write_buffer <= 0;
		write_parity <= 0;
		TX <= 1;
	end

	else if (uart_clk & write_active) begin
		write_tick <= write_tick + 1;
		if (write_tick == 0) begin
			write_count <= write_count + 1;
			if (write_count == 0) begin
				TX <= 0;
			end else begin
				TX <= write_buffer[0];
				write_buffer <= write_buffer >> 1;
				write_parity <= write_parity ^ write_buffer[0];
			end

			if (PARITY && write_count == 9)
				TX <= write_parity;

			if (write_count >= (PARITY ? 10 : 9))
				TX <= 1;
			
			if (write_count == (PARITY ? 11 : 10))
				write_active <= 0;
		end
	end

	else if (TX_READY & TX_VALID) begin
		write_active <= 1;
		write_count <= 0;
		write_buffer <= TX_DATA;
		write_parity <= 0;
	end
end

assign TX_READY = ~write_active;


endmodule

