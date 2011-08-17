module LOGIC_BLOCK (
	PCLK, PRST,
	UCLK, URST,
	IN,
	SIN, SE,
	OUT,
	SOUT
);


parameter N_BLE = 4;
parameter N_INPUT = 12;

input PCLK, PRST;
input UCLK, URST;
input [N_INPUT-1:0] IN;
input SIN, SE;
output [N_BLE-1:0] OUT;
output SOUT;

parameter N_BLE_PINS = 6;
parameter N_CONTROL_BITS = 4;
parameter N_SELECT = N_BLE * N_BLE_PINS * N_CONTROL_BITS;


wire [N_BLE+N_INPUT-1:0] inputs = { IN, OUT };
wire [N_BLE:0] shift;


reg [N_SELECT-1:0] select;

always @ (posedge PCLK) begin
	if (PRST)
		select <= 0;
	else if (SE) begin
		select[N_SELECT-1:1] <= select[N_SELECT-2:0];
		select[0] <= shift[N_BLE];
	end
end


// set shift in and shift out values
assign shift[0] = SIN;
assign SOUT = select[N_SELECT-1];


// generate BLEs
genvar i, j;
generate
	for (i = 0; i < N_BLE; i = i+1) begin : ELEMENT
		wire [N_BLE_PINS-1:0] ble_in;

		// create input crossbar mux
		for (j = 0; j < N_BLE_PINS; j = j+1) begin : XBAR_MUX
			//integer start = N_BLE_PINS * N_CONTROL_BITS * i + N_CONTROL_BITS * j;
			assign ble_in[j] = inputs[select[N_BLE_PINS * N_CONTROL_BITS * i + N_CONTROL_BITS * j+N_CONTROL_BITS-1:N_BLE_PINS * N_CONTROL_BITS * i + N_CONTROL_BITS * j]];
		end
		
		// create BLE instance
		BLE ble_inst (
			.PCLK(PCLK),
			.PRST(~PRST),
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

