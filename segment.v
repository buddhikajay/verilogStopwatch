`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:23:09 10/07/2016 
// Design Name: 
// Module Name:    segment 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module segment(
		input clk,
		output [7:0] segment,
		output clockOut,
		output [1:0] counter_reg,
		output  [3:0] digit_value,
		output [3:0] anodes,
		input start,
		input stop,
		input reset,
		output reg started = 0,
		output reg resetted = 0
    );	
		
		wire [3:0] reg0;
		wire [3:0] reg1;
		wire [3:0] reg2;
		wire [3:0] reg3;
		
		wire d0_in;
		wire d0_out;
		wire d1_out;
		wire d2_out;
		wire d3_out;
		
		
		
		//digit_reg digit_reg_1(.carryIn(clockOut), .rst(rst), .carryOut(carryOut), .value(regx));
		digit digit0(.clk(clockOut & started), .carryOut(d0_out), .value(reg0), .reset(reset));
		digit digit1(.clk(d0_out), .carryOut(d1_out), .value(reg1), .reset(reset));
		digit digit2(.clk(d1_out), .carryOut(d2_out), .value(reg2), .reset(reset));
		digit digit3(.clk(d2_out), .carryOut(d3_out), .value(reg3), .reset(reset));
		
		bcd_decoder bcd_decoder(.bcd_in(digit_value), .segment_out(segment));
		msClock msClock(.systemClock(clk), .clockOut(clockOut));
		two_bit_counter counter (.clk(clockOut), .counter_reg(counter_reg));
		two_to_four_dec two_to_four_dec(.in(counter_reg), .out(anodes));
		mux mux(.selector(counter_reg), .reg0(reg0), .reg1(reg1), .reg2(reg2), .reg3(reg3), .out(digit_value));

	
		always @(posedge clk)
			begin
				assign resetted = reset;
				if(start)
					assign started = 1;
				else if (stop)
					assign started = 0;
			end
		
endmodule

module two_to_four_dec(
	input [1:0] in,
	output [3:0] out
	);
	
	reg [3:0] muxReg;
	assign out = muxReg;

	always @(in)
		begin
			case (in)
				0 : muxReg = 14;
				1 : muxReg = 13;
				2 : muxReg = 11;
				3 : muxReg = 7;
				default : muxReg = 15;
			endcase
		end
endmodule


module msClock(
	input systemClock,
	output reg clockOut
	);
	reg [25:0] clockCounter;
	always @(posedge systemClock)
		begin
			if(clockCounter>=50000)
				begin
					clockOut <= !clockOut;
					clockCounter <= 0;
				end
			else
				begin
					clockCounter <= clockCounter +1;
				end
				
		end
endmodule



module bcd_decoder(
		input [3:0] bcd_in,
		output reg [7:0] segment_out
    );
	 
	always @(bcd_in)
		begin
			case (bcd_in)
				0 : segment_out = 192;
				1 : segment_out = 249;
				2 : segment_out = 164;
				3 : segment_out = 176;
				4 : segment_out = 153;
				5 : segment_out = 146;
				6 : segment_out = 130;
				7 : segment_out = 248;
				8 : segment_out = 128;
				9 : segment_out = 152;
				10 : begin segment_out = 192; end
				11 : begin segment_out = 249; end
				12 : begin segment_out = 164; end
				13 : begin segment_out = 176; end
				14 : begin segment_out = 153; end
				15 : begin segment_out = 146; end
				default : begin segment_out = 192; end
			endcase
		end
endmodule

module two_bit_counter(
	input clk,
	output reg [1:0] counter_reg
);

	always @(posedge clk)
		begin
			if(counter_reg == 3)
				counter_reg <= 0;
			else
				counter_reg <= counter_reg +1;
		end
endmodule

module digit(
		input clk,
		output reg carryOut, 
		output reg [3:0] value,
		input reset
	);
	always @(posedge clk or posedge reset)
		begin
			if(reset)
				value =0;
			else
				begin
					if(value == 9)
						begin
							value = 0;
							carryOut = 1;
						end
					else
						begin
							value = value +1;
							carryOut = 0;
						end
				end
		end
endmodule

module mux(
	input [1:0] selector,
	input [3:0] reg0,
	input [3:0] reg1,
	input [3:0] reg2,
	input [3:0] reg3,
	output reg [3:0] out
);

	always @(selector)
		begin
			case(selector)
				0: out = reg0;
				1: out = reg1;
				2: out = reg2;
				3: out = reg3;
				default : out = reg2;
			endcase
		end	
endmodule
