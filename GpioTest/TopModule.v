
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

//Serial
assign serial_tx = serial_rx;

wire [7:0]rbyte;
wire [3:0]num_bits;
wire rbyte_ready;
serial serial_inst(
	.clk( clk100 ),
	.rx( serial_rx ),
	.rx_byte(rbyte),
	.rbyte_ready(rbyte_ready),
	.onum_bits(num_bits)
);

reg [7:0]rxbyte0;
reg [7:0]rxbyte1;
reg rbyte_ready_;
always @(posedge clk100 )
begin
	rbyte_ready_ <= rbyte_ready;
	if(rbyte_ready)
	begin
		rxbyte1 <= rxbyte0;
		rxbyte0 <= rbyte;
	end
end

//KEYs & LEDs
reg [31:0]counter=32'hF0F0F0F0;
always @(posedge clk50)
	if( key[0]==1'b0 ) //reset
		counter <= 32'h0;
	else
	if( key[1]==1'b0 ) //count backward
		counter <= counter-1;
	else
		counter <= counter+1;

assign led = {
			counter[24],
			counter[25],
			counter[26],
			counter[27],
			counter[28],
			counter[29],
			counter[30],
			counter[31]
			};

// 7-Segment Dynamic display
wire [7:0]seg;
seg4x7 seg4x7_inst(
	.clk( clk50 ),
	.in( { rxbyte0, rxbyte1 } ),
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

reg [23:0]gpio_a_r; assign gpio_a = gpio_a_r;
reg [10:0]gpio_b_r; assign gpio_b = gpio_b_r;
reg [23:0]gpio_c_r;
//assign gpio0 = gpio_c_r[0];
//assign gpio1 = gpio_c_r[1];
assign gpio2  = gpio_c_r[2];
assign gpio3  = gpio_c_r[3];
assign gpio4  = gpio_c_r[4];
assign gpio5  = gpio_c_r[5];
assign gpio6  = gpio_c_r[6];
//assign gpio7= gpio_c_r[7];
assign gpio8  = gpio_c_r[8];
assign gpio9  = gpio_c_r[9];
assign gpio10 = gpio_c_r[10];
//assign gpio11= gpio_c_r[11];
assign gpio12 = gpio_c_r[12];
assign gpio13 = gpio_c_r[13];
assign gpio14 = gpio_c_r[14];
assign gpio15 = gpio_c_r[15];
assign gpio16 = gpio_c_r[16];
assign gpio17 = gpio_c_r[17];
assign gpio18 = gpio_c_r[18];
assign gpio19 = gpio_c_r[19];
assign gpio20 = gpio_c_r[20];
assign gpio21 = gpio_c_r[21];
assign gpio22 = gpio_c_r[22];
assign gpio23 = gpio_c_r[23];
always @(posedge clk100)
	if(rbyte_ready_ && rxbyte1[7])
	begin
		if(rxbyte1[1:0]==2'd1) //GPIo_a
		begin
			gpio_a_r[ rxbyte0 ] <= rxbyte1[2];
		end
		if(rxbyte1[1:0]==2'd2) //GPIo_b
		begin
			gpio_b_r[ rxbyte0 ] <= rxbyte1[2];
		end
		if(rxbyte1[1:0]==2'd3) //GPIo_c
		begin
			gpio_c_r[ rxbyte0 ] <= rxbyte1[2];
		end
	end

endmodule
