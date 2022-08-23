module spi_flash #(
    parameter DW = 128,
    parameter AW = 32,
    parameter IDW= 8
)(
    input           spi_flash_aclk,
    input           spi_flash_aresetn,

    input [IDW-1:0] spi_flash_awid,
    input [AW-1:0]  spi_flash_awaddr,
    input [7:0]     spi_flash_awlen,
    input [2:0]     spi_flash_awsize,
    input [1:0]     spi_flash_awburst,
    input           spi_flash_awlock,
    input [2:0]     spi_flash_awcache,
    input           spi_flash_awvalid,
    output          spi_flash_awready,

    input [DW-1:0]  spi_flash_wdata,
    input [(DW>>3)-1:0] spi_flash_wstrb,
    input           spi_flash_wlast,
    input           spi_flash_wvalid,
    output          spi_flash_wready,

    output[IDW-1:0] spi_flash_bid,
    output[1:0]     spi_flash_bresp,
    output          spi_flash_bvalid,
    input           spi_flash_bready,

    input [IDW-1:0] spi_flash_arid,
    input [AW-1:0]  spi_flash_araddr,
    input [7:0]     spi_flash_arlen,
    input [2:0]     spi_flash_arsize,
    input [1:0]     spi_flash_arburst,
    input           spi_flash_arvalid,
    output          spi_flash_arready,

    output[IDW-1:0] spi_flash_rid,
    output[DW-1:0]  spi_flash_rdata,
    output[1:0]     spi_flash_rresp,
    output          spi_flash_rlast,
    output          spi_flash_rvalid,
    input           spi_flash_rready,

    output[3:0]     spi_flash_csen,
    output[3:0]     spi_flash_csn_o,
    input [3:0]     spi_flash_csn_i,
    output          spi_flash_sdo_en,
    output          spi_flash_sdo_o,
    input           spi_flash_sdo_i,
    output          spi_flash_sdi_en,
    output          spi_flash_sdi_o,
    input           spi_flash_sdi_i
);


    wire            clk                 =   spi_flash_aclk;
    wire            rst_n               =   spi_flash_aresetn;


    wire            spi_flash_aw_hsked  =   spi_flash_awvalid & spi_flash_awready;
    wire            spi_flash_w_hsked   =   spi_flash_wvalid  & spi_flash_wready;
    wire            spi_flash_b_hsked   =   spi_flash_bvalid  & spi_flash_bready;
    wire            spi_flash_ar_hsked  =   spi_flash_arvalid & spi_flash_arready;
    wire            spi_flash_r_hsked   =   spi_flash_rvalid  & spi_flash_rready & spi_flash_rlast;  

    wire [IDW-1:0]  spi_flash_buf_awid_r;
    wire [IDW-1:0]  spi_flash_buf_awid_nxt;
    
    dfflr #(IDW)    awid_dfflr(spi_flash_aw_hsked, spi_flash_buf_awid_nxt, spi_flash_buf_awid_r, clk, rst_n);


    wire [IDW-1:0]  spi_flash_buf_arid_r;
    wire [IDW-1:0]  spi_flash_buf_arid_nxt;
    
    dfflr #(IDW)    arid_dfflr(spi_flash_ar_hsked, spi_flash_buf_arid_nxt, spi_flash_buf_arid_r, clk, rst_n);


    assign          spi_flash_bid       =   spi_flash_buf_awid_r;
    assign          spi_flash_rid       =   spi_flash_buf_arid_r;



    wire            spi_flash_buf_aw_vld_r;
    wire            spi_flash_buf_aw_vld_nxt;
    wire            spi_flash_buf_aw_vld_set;
    wire            spi_flash_buf_aw_vld_clr;
    wire            spi_flash_buf_aw_vld_ena;

    wire            spi_flash_buf_b_vld_r;
    wire            spi_flash_buf_b_vld_nxt;
    wire            spi_flash_buf_b_vld_clr;
    wire            spi_flash_buf_b_vld_set;
    wire            spi_flash_buf_b_vld_ena;

    
    assign          spi_flash_buf_aw_vld_set    =   spi_flash_aw_hsked;
    assign          spi_flash_buf_aw_vld_clr    =   spi_flash_w_hsked & spi_flash_wlast;
    assign          spi_flash_buf_aw_vld_ena    =   spi_flash_buf_aw_vld_set | spi_flash_buf_aw_vld_clr;
    assign          spi_flash_buf_aw_vld_nxt    =   spi_flash_buf_aw_vld_set | ~spi_flash_buf_aw_vld_clr;
    dfflr #(1)  spi_flash_buf_aw_vld_dfflr(spi_flash_buf_aw_vld_ena, spi_flash_buf_aw_vld_nxt, spi_flash_buf_aw_vld_r, clk, rst_n);


    assign          spi_flash_buf_b_vld_set     =   spi_flash_w_hsked & spi_flash_wlast;        
    assign          spi_flash_buf_b_vld_clr     =   spi_flash_b_hsked;
    assign          spi_flash_buf_b_vld_ena     =   spi_flash_buf_b_vld_set | spi_flash_buf_b_vld_clr;
    assign          spi_flash_buf_b_vld_nxt     =   spi_flash_buf_b_vld_set | ~spi_flash_buf_b_vld_clr;
    dfflr #(1)  spi_flash_buf_b_vld_dfflr(spi_flash_buf_b_vld_ena, spi_flash_buf_b_vld_nxt, spi_flash_buf_b_vld_r, clk,rst_n);


    

`ifdef  RESP_AT_ONCE
    assign          spi_flash_wready    =   spi_flash_buf_aw_vld_r;
    assign          spi_flash_awready   =   ~spi_flash_buf_aw_vld_r & ~spi_flash_buf_b_vld_r;
    assign          spi_flash_bvalid    =   spi_flash_buf_b_vld_r;
    assign          spi_flash_rlast     =   1'b1;

`endif



endmodule