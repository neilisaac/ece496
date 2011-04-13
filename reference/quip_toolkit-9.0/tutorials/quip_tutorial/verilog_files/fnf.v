// (C) 2004 Altera Corporation. All rights reserved. The design examples are 
// being provided on an "as-is" basis and as an accommodation and therefore 
// all warranties, representations or guarantees of any kind (whether express,
// implied or statutory) including, without limitation, warranties of 
// merchantability, non-infringement, or fitness for a particular purpose, 
// are specifically disclaimed.

// Simple registered NAND gate design for use in QUIP tutorial.
// "fnf" refers to Flip-flop -> NAND -> Flip-flop.
	
	module fnf (Input1, Input2, Clock, OutputPad);
	
// Declare two inputs and one output.
// Registers are clocked by signal Clock.
	input	 Input1, Input2, Clock;
	output   OutputPad;
	reg	 OutputReg;
	reg	 InputReg1, InputReg2;
	wire  RegIn;
	
// Connect Registers 
	always@(posedge Clock)
	begin
		InputReg1 <= Input1;
		InputReg2 <= Input2;
		OutputReg <= RegIn;
	end
	
//  Create NAND Function
	assign	RegIn = ~(InputReg1 & InputReg2);

//  Hook Output Register to the Output Pad

	assign	OutputPad = OutputReg;
		
	endmodule
