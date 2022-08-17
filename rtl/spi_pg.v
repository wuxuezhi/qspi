module spi_pg #(
    parameter   DW = 64,
    parameter   AS = 32,
    parameter   IDW=  8
)(
    input               spi_aclk,
    input               spi_aresetn,

    input [IDW-1:0]     spi_awid,
    input [AS-1:0]      spi_awaddr,
    input [1:0]         spi_awlen,
    input [2:0]         spi_awsize,
    input [1:0]         spi_awburst,
    input               spi_awvalid,
    output              spi_awready,

    input [DW-1:0]      spi_wdata,
    input [(DW>>3)-1:0] spi_wstrb,
    input               spi_wlast,
    input               spi_wvalid,
    output              spi_wready,

//     input               spi_arvalid,
//     input               spi_arready,
//     input               spi_rready,
//     input               spi_rvalid,
//     input               spi_rlast,

// //snooping spi port
//     input               spi_csn,

// spi output port
    output      o_spi_sck,
    output      o_spi_csn,
    output      o_spi_dq0_en,//MOSI
    // input       o_spi_dq0_i,
    output      o_spi_dq0_o,
    output      o_spi_dq1_en,//MISO
    // input       o_spi_dq1_i,
    output      o_spi_dq1_o,
    output      o_spi_dq2_en,
    // input       o_spi_dq2_i,
    output      o_spi_dq2_o,
    output      o_spi_dq3_en,
    // input       o_spi_dq3_i,
    output      o_spi_dq3_o
);
    wire        spi_aw_hsked        =   spi_awvalid & spi_awready;
    
    //TODO: modify  memory space for register.
    wire        spi_reg_space       =   (spi_awaddr[27:20] == 8'h18);

    //0x0       --- command meta information
    //0x4       --- write data queue.
    //
    //
    
    // -------------------------------------------------------
    // -- Command REGISTER
    // -------------------------------------------------------
    wire [31:0] spi_command_r;
    wire [31:0] spi_command_nxt;
    wire        spi_command_ena;

    


endmodule
