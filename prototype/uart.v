module uart (
	input main_clk,
	input reset,

	input rx,
	input in_valid,
	input [7:0] in_data,

	output out_clk,
	output active,

	output tx,
	output out_valid,
	output [7:0] out_data
);

// 9600 baud: 5208.333 50Mhz cycles (13 bit counter)
wire uart_clk;
delay # (5208, 13) uart_dly(main_clk, reset, uart_clk);
assign out_clk = uart_clk;

reg read, read_full;
reg [7:0] read_buf;
reg [2:0] read_count;

always @ (posedge main_clk or posedge reset) begin
	integer i;

	if (reset) begin
		read <= 0;
		read_full <= 0;
		read_count <= 0;
	end

	else if (main_clk & uart_clk) begin
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
	end
end

assign out_data = read_buf;
assign out_valid = read_full;

assign active = read; // TODO: add "| write"

endmodule

