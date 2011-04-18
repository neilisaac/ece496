module fitness (
	PIN_A13,
	PIN_B12,
	PIN_B13
);

input PIN_A13;
output PIN_B12;
output PIN_B13;

wire in1;
wire out1;
wire unused;

individual mutant (
	.in1(in1),
	.out1(out1),
	.tie_unused(unused)
);

assign in1 = PIN_A13;
assign PIN_B12 = out1;
assign PIN_B13 = unused;

endmodule

