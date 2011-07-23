module uart (
	input MAIN_CLK,			// main design clock
	input RESET,			// reset signal
	input RX,				// serial receiving line
	input IN_VALID,			// set high when input data is valid to send
	input [7:0] IN_DATA,	// bus for input data to send
	output ACTIVE,			// indication that serial port is in use
	output reg TX,			// serial transmitting line
	output IN_READY,		// uart module is ready to read data from user
	output OUT_VALID,		// output data is valid
	output [7:0] OUT_DATA	// bus for output data (must be buffered as soon as OUT_VALID goes high)
);

// 9600 baud: 10416.666 100Mhz cycles (14 bit counter)
// 115200 baud: 868.055 100Mhz cycles (10 bit counter)
wire read_clk, write_clk;
delay # (868, 10) read_clk_dly (MAIN_CLK, RESET, read_clk);
delay # (868, 10) write_clk_dly (MAIN_CLK, RESET, write_clk);


reg read, read_full;
reg [7:0] read_buf;
reg [2:0] read_count;

reg write, write_busy;
reg [7:0] write_buf;
reg [3:0] write_count;

integer i;
always @ (posedge MAIN_CLK) begin

	if (RESET) begin
		read <= 0;
		read_full <= 0;
		read_count <= 0;

		write <= 0;
		write_busy <= 0;
		write_count <= 0;
	end

	else begin
		if (read_clk) begin
			if (read) begin
				read_count <= read_count + 1;
				read_buf[7] <= RX;

				for (i = 0; i < 7; i = i + 1)
					read_buf[i] <= read_buf[i+1];

				if (read_count == 7) begin
					read <= 0;
					read_full <= 1;
				end
			end

			else if (~RX) begin
				read <= 1;
				read_count <= 0;
			end
		end

		else begin
			read_full <= 0;
		end

		if (write_clk) begin
			if (write) begin
				write_count <= write_count + 1;

				if (write_count == 0)
					TX <= 0;

				else if (write_count <= 8) begin
					TX <= write_buf[0];

					for (i = 0; i < 7; i = i + 1)
						write_buf[i] <= write_buf[i+1];
				end

				else begin
					TX <= 1;
					write <= 0;
					write_busy <= 0;
					write_count <= 0;
				end
			end

			else begin
				TX <= 1;
			end
		end

		if (IN_VALID & ~write) begin
			write <= 1;
			write_busy <= 1;
			write_count <= 0;
			write_buf <= IN_DATA;
		end
	end
end


assign OUT_DATA = read_buf;
assign OUT_VALID = read_full;
assign IN_READY = ~IN_VALID & ~write_busy;
assign ACTIVE = read | write;


endmodule

