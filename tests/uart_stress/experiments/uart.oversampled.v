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


parameter FREQ = 100000000;
parameter BAUD = 9600;
parameter COUNT = FREQ / (BAUD * 8);

reg [20:0] clk_count;
wire uart_clk = (clk_count == COUNT - 1);

always @ (posedge SCLK)
	clk_count <= (clk_count == COUNT) ? 0 : clk_count + 1;


reg read;
reg [2:0] read_tick, read_phase;
reg [3:0] read_count;

always @ (posedge SCLK) begin
	RX_VALID <= 0;

	if (RESET) begin
		read <= 0;
		read_count <= 0;
		RX_DATA <= 0;
	end

	else if (uart_clk & read) begin
		if (read_tick == read_phase) begin
			if (read_count == 9) begin
				RX_VALID <= 1;
				read <= 0;
			end else begin
				RX_DATA <= { RX, RX_DATA[7:1] };
				read_count <= read_count + 1;
			end
		end

		read_tick <= read_tick + 1;
	end

	else if (~read & ~RX) begin
		read <= 1;
		read_count <= 0;
		read_phase <= read_tick + 4;
	end
end


reg write;
reg [2:0] write_tick;
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
		if (write_tick == 0) begin
			TX <= write_buffer[0];
			write_buffer <= write_buffer >> 1;
			write_count <= write_count + 1;

			if (write_count >= 8)
				TX <= 1;
			
			if (write_count == 9)
				write <= 0;
		end

		write_tick <= write_tick + 1;
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

