`timescale 1ns / 1ps

module testbench;

parameter `CLB_INPUTS = 16;
parameter `BLE_PER_CLB = 4;
parameter `TRACKS = 2;

reg clk, rst;
reg [7:0] inputs;
reg user_clock;
reg user_reset;

wire [7:0] outputs;

initial begin
	clk = 0;
	rst = 1;
	inputs = 0;
	user_clock = 0;
	user_reset = 0;
	#1 rst = 0;
end

always
	#1 clk = ~clk;

always @ (posedge clk)
	inputs <= inputs + 1;

wire shift_head;
wire shift_enable;

SCAN_TB scan_tb_inst ( shift_head, shift_enable );

OVERLAY # (
	.`CLB_INPUTS		(`CLB_INPUTS),
	.`BLE_PER_CLB		(`BLE_PER_CLB),
	.`TRACKS		(`TRACKS)
) overlay_inst (
	.PCLK			(clk),
	.PRST			(rst),
	.UCLK			(user_clock),
	.URST			(user_reset),
	.SE				(shift_enable),
	.SIN			(shift_head),
	.SOUT			(),
	.INPUTS			(inputs),
	.OUTPUTS		(outputs)
);

endmodule



module SRLC32E (Q, Q31, A, CE, CLK, D);

parameter INIT = 32'h00000000;

input [4:0] A;
input CLK;
input CE;
input D;

output Q;
output Q31;

reg [31:0] bits;

always @ (posedge CLK)
	if (CE)
		bits <= { bits[31:1], D };

assign Q = bits[A];
assign Q31 = bits[31];

endmodule



module MUXF7 (O, I0, I1, S);

input I0;
input I1;
input S;
output O;

assign O = S ? I1 : I0;

endmodule


