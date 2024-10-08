
`timescale 1ns/1ps 

module tb;

reg rst=1'b0;
reg i_clk  =1'b0;
reg i_clk_s =1'b0;
always @(*) begin
	i_clk   <= #5 ~i_clk;
	i_clk_s <= #4340 ~i_clk_s;
end 

reg line_rx;

wire [7:0]rbyte;
wire rbyte_ready;
serial S(
	.clk(i_clk),
	.rx(line_rx),
	.rx_byte(rbyte),
	.rbyte_ready(rbyte_ready),
	.onum_bits()
	);

initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);
	line_rx = 1'b1;

	rst = 1'b1;
	#20;
	rst = 1'b0;

	#200000;
	send_byte( 8'h53 );	//write addr
	//send_byte( 8'h35 );	//write addr
	
	#5000;
	$finish(0);
end

task send_byte;
input [7:0]sb;
begin
	@(posedge i_clk_s);
	line_rx = 1'b0;
	@(posedge i_clk_s);
	line_rx = sb[0];
	@(posedge i_clk_s);
	line_rx = sb[1];
	@(posedge i_clk_s);
	line_rx = sb[2];
	@(posedge i_clk_s);
	line_rx = sb[3];
	@(posedge i_clk_s);
	line_rx = sb[4];
	@(posedge i_clk_s);
	line_rx = sb[5];
	@(posedge i_clk_s);
	line_rx = sb[6];
	@(posedge i_clk_s);
	line_rx = sb[7];
	@(posedge i_clk_s);
	line_rx = 1'b1;
end
endtask

endmodule