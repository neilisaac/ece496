module uart (
	input main_clk,
	input reset,

	input rx,
	input in_valid,
	input [7:0] in_data,

	output out_clk,
	output active,

	output reg tx,
	output in_ready,
	output out_valid,
	output [7:0] out_data
);

// 9600 baud: 5208.333 50Mhz cycles (13 bit counter)
wire uart_clk;
delay # (5208, 13) uart_dly (main_clk, reset, uart_clk);

reg read, read_full;
reg [7:0] read_buf;
reg [2:0] read_count;

reg write, write_ready;
reg [7:0] write_buf;
reg [3:0] write_count;

always @ (posedge main_clk or posedge reset) begin
	integer i;

	if (reset) begin
		read <= 0;
		read_full <= 0;
		read_count <= 0;

		write <= 0;
		write_ready <= 1;
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
					tx <= write_buf[7];

					for (i = 0; i < 7; i = i + 1)
						write_buf[i+1] <= write_buf[i];
				end

				else begin
					write <= 0;
					write_ready <= 1;
					write_count <= 0;
				end
			end
		end

		if (in_valid & ~write) begin
			write <= 1;
			write_ready <= 0;
			write_count <= 0;
			write_buf <= in_data;
		end
	end
end


assign out_clk = uart_clk;
assign out_data = read_buf;
assign out_valid = read_full;
assign in_ready = write_ready;
assign active = read | write;


endmodule

