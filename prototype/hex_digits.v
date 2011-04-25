module hex_digits (
	input [3:0] value,
	output [6:0] leds
);

wire [3:0] x = value;

assign leds[0] = 	(~x[3] & ~x[2] & ~x[1] & x[0]) |
					(~x[3] & x[2] & ~x[1] & ~x[0]) |
					(x[3] & x[2] & ~x[1] & x[0]) |
					(x[3] & ~x[2] & x[1] & x[0]);

assign leds[1] = 	(~x[3] & x[2] & ~x[1] & x[0]) |
					(x[3] & x[1] & x[0]) |
					(x[3] & x[2] & ~x[0]) |
					(x[2] & x[1] & ~x[0]);

assign leds[2] = 	(x[3] & x[2] & ~x[0]) |
					(x[3] & x[2] & x[1]) |
					(~x[3] & ~x[2] & x[1] & ~x[0]);

assign leds[3] =	(~x[3] & ~x[2] & ~x[1] & x[0]) | 
					(~x[3] & x[2] & ~x[1] & ~x[0]) | 
					(x[2] & x[1] & x[0]) | 
					(x[3] & ~x[2] & x[1] & ~x[0]);

assign leds[4] = 	(~x[3] & x[0]) |
					(~x[3] & x[2] & ~x[1]) |
					(~x[2] & ~x[1] & x[0]);

assign leds[5] = 	(~x[3] & ~x[2] & x[0]) | 
					(~x[3] & ~x[2] & x[1]) | 
					(~x[3] & x[1] & x[0]) | 
					(x[3] & x[2] & ~x[1] & x[0]);

assign leds[6] = 	(~x[3] & ~x[2] & ~x[1]) | 
					(x[3] & x[2] & ~x[1] & ~x[0]) | 
					(~x[3] & x[2] & x[1] & x[0]);
	
endmodule

