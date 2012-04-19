`include "params.v"

module CONNECTION_BLOCK(LB1_IN, LB2_IN, SB1_IN, SB2_IN, LB1_OUT, LB2_OUT, SB1_OUT, SB2_OUT, CLK, SE, SIN, SOUT);

parameter W = `TRACKS;        // size of interconnecting bus (one way)
parameter O = `CLB_INPUTS/4;   //size of input into logic blocks
parameter P = `BLE_PER_CLB/4; //size of output from logic blocks

input [P-1:0] LB1_IN; //input into the connection block from logic block 1
input [P-1:0] LB2_IN; //input into the connection block from logic block 2
input [W-1:0] SB1_IN;
input [W-1:0] SB2_IN;
input CLK;
input SE;
input SIN;
output [O-1:0] LB1_OUT; //input into logic block 1 from the connection block
output [O-1:0] LB2_OUT; //input into logic block 2 from the connection block
output [W-1:0] SB1_OUT;
output [W-1:0] SB2_OUT;
output SOUT;

wire [W*2-1:0] cb_input = {SB2_IN, SB1_IN}; //merged input from both directions of connection block
wire [P*2-1:0] lb_input = {LB2_IN, LB1_IN}; //merged input from both adjacent logic blocks
wire [O*2+W*2:0] scan_chain;

assign scan_chain[0] = SIN;

genvar i;
generate //generate muxes into logic block 1
	for (i=0; i<O; i=i+1) begin : LB1OUTMux
		XBAR # (.N(W*2+1)) LB1OUTMux_inst (
			.A({cb_input, LB2_IN[0]}),
			.SE(SE),
			.CLK(CLK),
			.SIN(scan_chain[i]),
			.Z(LB1_OUT[i]),
			.SOUT(scan_chain[i+1])
		);
	end
endgenerate

generate //generate muxes into logic block 2
	for (i=0; i<O; i=i+1) begin : LB2OUTMux
		XBAR # (.N(W*2+1)) LB2OUTMux_inst (
			.A({cb_input, LB1_IN[0]}),
			.SE(SE),
			.CLK(CLK),
			.SIN(scan_chain[O+i]),
			.Z(LB2_OUT[i]),
			.SOUT(scan_chain[O+i+1])
		);
	end
endgenerate

generate //generate muxes for CB output in direction 1
	for (i=0; i<W; i=i+1) begin : SB1OUTMux
		XBAR # (.N(P*2+1)) CB1OUTMux_inst (
			.A({lb_input,SB2_IN[i]}),
			.SE(SE),
			.CLK(CLK),
			.SIN(scan_chain[2*O+i]),
			.Z(SB1_OUT[i]),
			.SOUT(scan_chain[2*O+i+1])
		);
	end
endgenerate

generate //generate muxes for CB output in direction 2
	for (i=0; i<W; i=i+1) begin : SB2OUTMux
		XBAR # (.N(P*2+1)) CB2OUTMux_inst (
			.A({lb_input,SB1_IN[i]}),
			.SE(SE),
			.CLK(CLK),
			.SIN(scan_chain[2*O+W+i]),
			.Z(SB2_OUT[i]),
			.SOUT(scan_chain[2*O+W+i+1])
		);
	end
endgenerate

assign SOUT = scan_chain[2*O+2*W];

endmodule

