
module TopModule(
		input wire clk,
		input wire [1:0]key,
		
		input wire serial_rx,
		output wire serial_tx,
		
		output wire [7:0]led,
		
		//7-Segment Indicator
		output wire seg_a,
		output wire seg_b,
		output wire seg_c,
		output wire seg_d,
		output wire seg_e,
		output wire seg_f,
		output wire seg_g,
		output wire seg_p,
		output wire [3:0]seg_sel,

		//Raspberry GPIO pins
		//input wire gpio0, //JTAG TMS
		//input wire gpio1, //JTAG TDO
		inout wire gpio2,
		inout wire gpio3,
		inout wire gpio4,
		inout wire gpio5,
		inout wire gpio6,
		//input wire gpio7, //JTAG TCK
		inout wire gpio8,
		inout wire gpio9,
		inout wire gpio10,
		//input wire gpio11, //JTAG TDI
		inout wire gpio12,
		inout wire gpio13,
		inout wire gpio14,
		inout wire gpio15,
		inout wire gpio16,
		inout wire gpio17,
		inout wire gpio18,
		inout wire gpio19,
		inout wire gpio20,
		inout wire gpio21,
		inout wire gpio22,
		inout wire gpio23,
		input wire gpio24_i,
		input wire gpio25_i,
		input wire gpio26_i,
		input wire gpio27_i,

		inout wire [23:0]gpio_a,	/* bidir GPIOs */
		input wire [ 3:0]gpio_a_i,  /* GPIO27, GPIO26, GPIO25, GPIO24 are only inputs */
		
		inout wire [10:0]gpio_b,	/* some pins can be output or bidir, other can be only input*/
		input wire [2:0]gpio_b_i,
		
		//PCM1801 or PCM 1808 ADC
		output wire pcm_scki,
		output wire pcm_lrck,
		output wire pcm_bck,
		//output wire pcm_cfg_fmt,
		//output wire pcm_cfg_md0,
		//output wire pcm_cfg_md1,
		input wire  pcm_dout,

		//audio output delta-sigma
		output wire sound_out_l,
		output wire sound_out_r,

		//serial flash interface
		output wire flash_csb,
		output wire flash_clk,
		inout  wire flash_io0,
		inout  wire flash_io1,
		inout  wire flash_io2,
		inout  wire flash_io3,
			
		/* Interface to SDRAM chip  */
		output wire mem_clk,
		//output wire mem_cke,		// SDRAM CKE
		//output wire mem_cs,		// SDRAM Chip Select

		output wire mem_ras,		// SDRAM ras
		output wire mem_cas,		// SDRAM cas
		output wire mem_we,		// SDRAM write enable
		output wire [3:0]mem_dqm, // SDRAM Data Mask
		output wire [1:0]mem_ba,	// SDRAM Bank Enable
		output wire [11:0]mem_a,	// SDRAM Address
		inout  wire [31:0]mem_dq // SDRAM Data Input/output		            
);

wire clk50;
wire clk100;
MyPLL mypll_inst(
	.inclk0(clk),
	.c0(clk50),
	.c1(clk100)
);

//capture LEDs value from Raspberry GPIO
reg [7:0]led_r = 8'h00;
assign led = led_r;
always @(posedge clk100)
	led_r <= { gpio23,gpio22,gpio21,gpio20, gpio19,gpio18,gpio17,gpio16};

wire [7:0]rbyte;
wire rbyte_ready;
serial S(
	.clk( clk100 ),
	.rx( gpio14 ),
	.rx_byte(rbyte),
	.rbyte_ready(rbyte_ready),
	.onum_bits()
	);

reg [3:0]rxdots   = 4'h0;
reg [3:0]rxdots_  = 4'h0;
reg [15:0]rxword  = 16'h0000;
reg [15:0]rxword_ = 16'h0000;
always @(posedge clk100 )
	if( key[0]==1'b0 ) //reset
	begin
		rxword  <= 16'hFFFF;
		rxword_ <= 16'hFFFF;
		rxdots  <= 4'hF;
		rxdots_ <= 4'hF;
	end
	else
	if(rbyte_ready)
	begin
		rxword  <= { rxword[11:0],rbyte[3:0] };
		rxdots  <= { rxdots[2:0], rbyte[4]   }; //bit 4 is dot in 7seg
		//8th bit of received byte allow display accumulated value in rxword_
		if( rbyte[7]==1'b1 )
		begin
			rxword_ <= { rxword[11:0],rbyte[3:0] };
			rxdots_ <= { rxdots[2:0], rbyte[4]   };
		end
	end

// 7-Segment Dynamic display
wire [7:0]seg;
seg4x7 seg4x7_inst(
	.clk( clk50 ),
	.in( rxword_ ),
	.in_dots( rxdots_ ),
	.digit_sel( seg_sel ),
	.out( seg )
);

//	7-Segment pins: bAfCgD.e  
assign seg_b = seg[7];
assign seg_a = seg[6];
assign seg_f = seg[5];
assign seg_c = seg[4];
assign seg_g = seg[3];
assign seg_d = seg[2];
assign seg_p = seg[1];
assign seg_e = seg[0];

endmodule
