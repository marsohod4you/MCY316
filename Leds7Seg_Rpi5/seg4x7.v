module seg4x7(
	input		wire	clk,			// 100MHZ
	input		wire	[15:0] in,
	input		wire	[ 3:0] in_dots,
	output	reg	[3:0] digit_sel,
	output	reg	[7:0] out
);

reg     [19:0] cnt;
always @ (posedge clk)
	cnt <= cnt +1'b1;

wire [1:0]digit_idx; assign digit_idx = cnt[19:18];
always @ (posedge clk)
	digit_sel <= 4'b0001 << digit_idx;

wire [3:0]a;
assign a = 	digit_sel[0] ? in[15:12] : 
				digit_sel[1] ? in[11:8] : 
				digit_sel[2] ? in[7:4]: in[3:0];
wire [7:0]d;
assign d =  { 6'h3F,
				~(	digit_sel[0] ? in_dots[3] :
					digit_sel[1] ? in_dots[2] :
					digit_sel[2] ? in_dots[1] : in_dots[0]),
				1'b1 };
	
always @ (posedge clk)
begin
	case(a)
		//	bAfCgD.e  
		4'h0:out <= 8'b00001010&d;//0
		4'h1:out <= 8'b01101111&d;//1
		4'h2:out <= 8'b00110010&d;//2
		4'h3:out <= 8'b00100011&d;//3
		4'h4:out <= 8'b01000111&d;//4
		4'h5:out <= 8'b10000011&d;//5
		4'h6:out <= 8'b10000010&d;//6
		4'h7:out <= 8'b00101111&d;//7
		4'h8:out <= 8'b00000010&d;//8
		4'h9:out <= 8'b00000011&d;//9
		4'ha:out <= 8'b00000110&d;//a
		4'hb:out <= 8'b11000010&d;//b
		4'hc:out <= 8'b10011010&d;//c
		4'hd:out <= 8'b01100010&d;//d
		4'he:out <= 8'b10010010&d;//e
		4'hf:out <= 8'b10010110&d;//f
	endcase
end

endmodule
