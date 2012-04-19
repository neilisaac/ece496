`include "params.v"

module LOGIC_BLOCK (
	PCLK, PRST,
	UCLK, URST,
	IN,
	SIN, SE,
	OUT,
	SOUT
);

input PCLK, PRST;
input UCLK, URST;
input [`CLB_INPUTS-1:0] IN;
input SIN, SE;
output [`BLE_PER_CLB-1:0] OUT;
output SOUT;


wire [`BLE_PER_CLB+`CLB_INPUTS-1:0] inputs = { IN, OUT };
wire [`BLE_PER_CLB:0] shift;

wire [`BLE_PER_CLB*`LUT_PINS:0] xbar_shift;
assign xbar_shift[0] = shift[`BLE_PER_CLB];

// set shift in and shift out values
assign shift[0] = SIN;
assign SOUT = xbar_shift[`BLE_PER_CLB*`LUT_PINS];


// generate BLEs
genvar i, j;
generate
	for (i = 0; i < `BLE_PER_CLB; i = i+1) begin : ELEMENT
		wire [`LUT_PINS-1:0] ble_in;

		// create input crossbar mux
		for (j = 0; j < `LUT_PINS; j = j+1) begin : XBAR_MUX
			XBAR #(.N(`BLE_PER_CLB+`CLB_INPUTS)) xbar_mux_inst(inputs, SE, PCLK, xbar_shift[i*`LUT_PINS+j], ble_in[j], xbar_shift[i*`LUT_PINS+j+1]);
		end
		
		// create BLE instance
		BLE6 ble_inst (
			.PCLK(PCLK),
			.PRST(PRST),
			.UCLK(UCLK),
			.URST(URST),
			.A(ble_in),
			.SIN(shift[i]),
			.SOUT(shift[i+1]),
			.SE(SE),
			.F(OUT[i])
		);
	end
endgenerate


endmodule

