
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

reg [31:0]cnt;
always @(posedge clk)
	cnt <= cnt+1;
assign led = { 7'h0, cnt[22]};

//This component allows to load FPGA external boot flash
altserial_flash_loader altserial_flash_loader_component (
                .noe (),
                .asmi_access_granted (),
                .asmi_access_request (),
                .data0out (),
                .data_in (),
                .data_oe (),
                .data_out (),
                .dclkin (),
                .scein (),
                .sdoin ()
                );

endmodule
