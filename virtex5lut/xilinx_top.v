module xilinx_top(
	input fpga_0_clk_1_sys_clk_pin,
	input fpga_0_rst_1_sys_rst_pin,
	input [4:0] fpga_0_Push_Buttons_5Bit_GPIO_IO_pin,
	input [7:0] fpga_0_DIP_Switches_8Bit_GPIO_IO_pin,
	input fpga_0_RS232_Uart_1_sin_pin,
	output fpga_0_RS232_Uart_1_sout_pin,
	output [4:0] fpga_0_LEDs_Positions_GPIO_IO_pin,
	output [7:0] fpga_0_LEDs_8Bit_GPIO_IO_pin
);

master master_inst (
	.clock_pin(fpga_0_clk_1_sys_clk_pin),
	.reset_pin(fpga_0_rst_1_sys_rst_pin),
	.button_pins(fpga_0_Push_Buttons_5Bit_GPIO_IO_pin),
	.switch_pins(fpga_0_DIP_Switches_8Bit_GPIO_IO_pin),
	.uart_in_pin(fpga_0_RS232_Uart_1_sin_pin),
	.uart_out_pin(fpga_0_RS232_Uart_1_sout_pin),
	.led_pins(fpga_0_LEDs_8Bit_GPIO_IO_pin)
);

assign fpga_0_LEDs_Positions_GPIO_IO_pin = 0;


endmodule

