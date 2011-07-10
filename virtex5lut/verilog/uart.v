module uart (
	input main_clk,			// main design clock
	input reset,			// reset signal

	input rx,				// serial receiving line
	input in_valid,			// set high when input data is valid to send
	input [7:0] in_data,	// bus for input data to send

	output out_clk,			// generated clock output
	output active,			// indication that serial port is in use

	output reg tx,			// serial transmitting line
	output in_ready,		// uart module is ready to read data from user
	output out_valid,		// output data is valid
	output [7:0] out_data	// bus for output data (must be buffered as soon as out_valid goes high)
);

// 9600 baud: 10416.666 100Mhz cycles (14 bit counter)
// 115200 baud: 868.055 100Mhz cycles (10 bit counter)
wire uart_clk;
delay # (868, 10) uart_dly (main_clk, reset, uart_clk);



reg read, read_full;
reg [7:0] read_buf;
reg [2:0] read_count;

reg write, write_busy;
reg [7:0] write_buf;
reg [3:0] write_count;

integer i;
always @ (posedge main_clk) begin

	if (reset) begin
		read <= 0;
		read_full <= 0;
		read_count <= 0;

		write <= 0;
		write_busy <= 0;
		write_count <= 0;
	end

	else if (main_clk) begin
		if (uart_clk) begin
			if (read) begin
				read_count <= read_count + 1;
				read_buf[7] <= rx;

				for (i = 0; i < 7; i = i + 1)
					read_buf[i] <= read_buf[i+1];

				if (read_count == 7) begin
					read <= 0;
					read_full <= 1;
				end
			end

			else if (~rx) begin
				read <= 1;
				read_count <= 0;
			end

			if (write) begin
				write_count <= write_count + 1;

				if (write_count == 0)
					tx <= 0;

				else if (write_count <= 8) begin
					tx <= write_buf[0];

					for (i = 0; i < 7; i = i + 1)
						write_buf[i] <= write_buf[i+1];
				end

				else begin
					tx <= 1;
					write <= 0;
					write_busy <= 0;
					write_count <= 0;
				end
			end

			else begin
				tx <= 1;
			end
		end

		else begin
			read_full <= 0;
		end

		if (in_valid & ~write) begin
			write <= 1;
			write_busy <= 1;
			write_count <= 0;
			write_buf <= in_data;
		end
	end
end



assign out_clk = uart_clk;
assign out_data = read_buf;
assign out_valid = read_full;
assign in_ready = ~in_valid & ~write_busy;
assign active = read | write;


endmodule

