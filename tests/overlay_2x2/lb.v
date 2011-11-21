module LOGIC_BLOCK (
	PCLK, PRST,
	UCLK, URST,
	IN,
	SIN, SE,
	OUT,
	SOUT
);


parameter N_BLE = 4;
parameter N_BLE_PINS = 6;
parameter N_INPUT = 24;

input PCLK, PRST;
input UCLK, URST;
input [N_INPUT-1:0] IN;
input SIN, SE;
output [N_BLE-1:0] OUT;
output SOUT;

wire [N_BLE+N_INPUT-1:0] inputs = { IN, OUT };
wire [N_BLE:0] shift;

wire [N_BLE*N_BLE_PINS:0] xbar_shift;
assign xbar_shift[0] = shift[N_BLE];

// set shift in and shift out values
assign shift[0] = SIN;
assign SOUT = xbar_shift[N_BLE*N_BLE_PINS];


// generate BLEs
genvar i, j;
generate
	for (i = 0; i < N_BLE; i = i+1) begin : ELEMENT
		wire [N_BLE_PINS-1:0] ble_in;

		// create input crossbar mux
		for (j = 0; j < N_BLE_PINS; j = j+1) begin : XBAR_MUX
			LayerMux #(.N(N_BLE+N_INPUT)) xbar_mux_inst(inputs, SE, PCLK, xbar_shift[i*N_BLE_PINS+j], ble_in[j], xbar_shift[i*N_BLE_PINS+j+1]);
		end
		
		// create BLE instance
		BLE ble_inst (
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

