module spi_axi_if #(
    parameter DW = 128,
    parameter AW = 32,
    parameter IDW = 6,
    parameter QSPI_HADDR =   24'h1fff02
)(
    input               aclk,
    input               aresetn,

    input [IDW-1:0]     spi_if_awid,
    input [AW-1:0]      spi_if_awaddr,
    input [7:0]         spi_if_awlen,
    input [2:0]         spi_if_awsize,
    input [1:0]         spi_if_awburst,
    input               spi_if_awlock,
    input [2:0]         spi_if_awcache,
    input               spi_if_awvalid,
    output              spi_if_awready,

    input [DW-1:0]      spi_if_wdata,
    input [(DW>>3)-1:0] spi_if_wstrb,
    input               spi_if_wlast,
    input               spi_if_wvalid,
    output              spi_if_wready,

    output[IDW-1:0]     spi_if_bid,
    output[1:0]         spi_if_bresp,
    output              spi_if_bvalid,
    input               spi_if_bready,

    input [IDW-1:0]     spi_if_arid,
    input [AW-1:0]      spi_if_araddr,
    input [7:0]         spi_if_arlen,
    input [2:0]         spi_if_arsize,
    input [1:0]         spi_if_arburst,
    input               spi_if_arvalid,
    output              spi_if_arready,

    output[IDW-1:0]     spi_if_rid,
    output[DW-1:0]      spi_if_rdata,
    output[1:0]         spi_if_rresp,
    output              spi_if_rlast,
    output              spi_if_rvalid,
    input               spi_if_rready,

    //spi signal
    output[3:0]         spi_if_csn_en,
    output[3:0]         spi_if_csn_o,
    input [3:0]         spi_if_csn_i,

    output              spi_if_sdo_en,
    output              spi_if_sdo_o,
    input               spi_if_sdo_i,

    output              spi_if_sdi_en,
    output              spi_if_sdi_o,
    input               spi_if_sdi_i

);


    wire                clk                 =   aclk;//alias
    wire                rst_n               =   aresetn;

    wire                spi_switch_r;
    wire                spi_switch_nxt;
    wire                spi_switch_ena;
    
    dfflr #(1)  spi_switch_dfflr(spi_switch_ena, spi_switch_nxt, spi_switch_r, clk, rst_n);

    localparam  AW_CHNL_W   =   IDW + 8 + 3 + 2 + 1 + 3 + AW;

    wire [AW_CHNL_W-1:0]i_axi_aw_chnl       =
        {
            spi_if_awid,
            spi_if_awlen,
            spi_if_awsize,
            spi_if_awburst,
            spi_if_awlock,
            spi_if_awcache
        };
    wire [AW_CHNL_W-1:0]o_axi_aw_chnl;
    wire                o_axi_aw_vld;
    wire                o_axi_aw_rdy;

    async_rst_fifo #(
        .DP(1),
        .DW(AW_CHNL_W)
    ) o_axi_aw_fifo(
        .i_rdy(spi_if_awready),
        .i_vld(spi_if_awvalid),
        .i_dat(i_axi_aw_chnl),
        .o_vld(o_axi_aw_vld),
        .o_rdy(o_axi_aw_rdy),
        .o_dat(o_axi_aw_chnl)
    );

    localparam  W_CHNL_W    =   DW + 1 + (DW>>3);

    wire [W_CHNL_W-1:0] i_axi_w_chnl    = {
        spi_if_wdata,
        spi_if_wlast,
        spi_if_wstrb
    }
    wire [W_CHNL_W-1:0] o_axi_w_chnl;
    wire                o_axi_w_vld;
    wire                o_axi_w_rdy;

    async_rst_fifo #(
        .DP(1),
        .DW(W_CHNL_W)
    ) o_axi_w_fifo(
        .i_rdy(spi_if_wready),
        .i_vld(spi_if_wvalid),
        .i_dat(i_axi_w_chnl),
        .o_vld(o_axi_w_vld),
        .o_rdy(o_axi_w_rdy),
        .o_dat(o_axi_w_chnl)
    );


    wire            spi_flash_busy;
    wire [IDW-1:0]  spi_flash_awid;
    wire [AW-1:0]   spi_flash_awaddr;
    wire [7:0]      spi_flash_awlen;
    wire [2:0]      spi_flash_awsize;
    wire [1:0]      spi_flash_awburst;
    wire            spi_flash_awlock;
    wire [2:0]      spi_flash_awcache;
    wire            spi_flash_awvalid;
    wire            spi_flash_awready;

    wire [DW-1:0]   spi_flash_wdata;
    wire [(DW>>3)-1:0]  spi_flash_wstrb;
    wire            spi_flash_wlast;
    wire            spi_flash_wvalid;
    wire            spi_flash_wready;

    wire [IDW-1:0]  spi_flash_bid;
    wire [1:0]      spi_flash_bresp;
    wire            spi_flash_bvalid;
    wire            spi_flash_bready;

    wire [IDW-1:0]  spi_flash_arid;
    wire [AW-1:0]   spi_flash_araddr;
    wire [7:0]      spi_flash_arlen;
    wire [2:0]      spi_flash_arsize;
    wire [1:0]      spi_flash_arburst;
    wire            spi_flash_arvalid;
    wire            spi_flash_arready;

    wire [IDW-1:0]  spi_flash_rid;
    wire [DW-1:0]   spi_flash_rdata;
    wire [1:0]      spi_flash_rresp;
    wire            spi_flash_rlast;
    wire            spi_flash_rvalid;
    wire            spi_flash_rready;

    // QSPI space
    wire    qspi_write_hit      =   (spi_if_awaddr[DW-1:8] == QSPI_HADDR);
    wire    qspi_read_hit       =   (spi_if_araddr[DW-1:8] == QSPI_HADDR);

    //spi flash 
    wire    spi_flash_wchnl_r;
    wire    spi_flash_wchnl_nxt;
    wire    spi_flash_wchnl_set;
    wire    spi_flash_wchnl_clr;
    wire    spi_flash_wchnl_ena;

    assign  spi_flash_wchnl_set =   spi_flash_awvalid   & spi_flash_awready;
    assign  spi_flash_wchnl_clr =   spi_flash_bvalid    & spi_flash_bready;
    assign  spi_flash_wchnl_ena =   spi_flash_wchnl_set & spi_flash_wchnl_clr;
    assign  spi_flash_wchnl_nxt =   spi_flash_wchnl_set & ~spi_flash_wchnl_clr;
    dfflr #(1) spi_flash_wchnl_dfflr(spi_flash_wchnl_ena, spi_flash_wchnl_nxt, spi_flash_wchnl_r, clk, rst_n);

    assign  spi_flash_awvalid   =   spi_if_awvalid & ~qspi_write_hit;
    assign  spi_flash_awaddr    =   spi_if_awaddr;
    assign  spi_flash_awlen     =   spi_if_awlen;
    assign  spi_flash_awsize    =   spi_if_awsize;
    assign  spi_flash_awburst   =   spi_if_awburst;
    assign  spi_flash_awlock    =
       spi_flash_wchnl_r   & spi_if_bready;

    wire    spi_flash_rchnl_r;
    wire    spi_flash_rchnl_nxt;
    wire    spi_flash_rchnl_set;
    wire    spi_flash_rchnl_clr;
    wire    spi_flash_rchnl_ena;

    assign  spi_flash_rchnl_set =   spi_flash_arvalid   & spi_flash_arready;
    assign  spi_flash_rchnl_clr =   spi_flash_rvalid    & spi_flash_rready & spi_flash_rlast;
    assign  spi_flash_rchnl_ena =   spi_flash_rchnl_set & spi_flash_rchnl_clr;
    assign  spi_flash_rchnl_nxt =   spi_flash_rchnl_set & ~spi_flash_rchnl_clr;
    dfflr #(1) spi_flash_rchnl_dfflr(spi_flash_rchnl_ena, spi_flash_rchnl_nxt, spi_flash_rchnl_r, clk, rst_n);

    assign  spi_flash_arvalid   =   spi_if_rvalid   & ~qspi_read_hit;
    assign  spi_flash_arid      =   spi_if_arid;
    assign  spi_flash_araddr    =   spi_if_araddr;
    assign  spi_flash_arlen     =   spi_if_arlen;
    assign  spi_flash_arsize    =   spi_if_arsize;
    assign  spi_flash_arburst   =   spi_if_arburst;
    
    //qspi channel
    wire        qspi_if_req_vld;
    wire        qspi_if_req_rdy;
    wire        qspi_if_req_read;
    wire [2:0]  qspi_if_req_addr;
    wire        qspi_if_req_read;
    wire [7:0]  qspi_if_req_dat;

    wire        qspi_if_rsp_vld;
    wire        qspi_if_rsp_rdy;
    wire [7:0]  qspi_if_rsp_dat;

    wire        qspi_if_sck;
    wire        qspi_if_csn;
    wire        qspi_if_dq0_en;
    wire        qspi_if_dq0_i;
    wire        qspi_if_dq0_o;  
    wire        qspi_if_dq1_en;
    wire        qspi_if_dq1_i;
    wire        qspi_if_dq1_o;  
    wire        qspi_if_dq2_en;
    wire        qspi_if_dq2_i;
    wire        qspi_if_dq2_o;  
    wire        qspi_if_dq3_en;
    wire        qspi_if_dq3_i;
    wire        qspi_if_dq3_o;

    
          

    wire    qspi_wchnl_r;
    wire    qpsi_wchnl_nxt;
    wire    qspi_wchnl_set;
    wire    qspi_wchnl_clr;
    wire    qspi_wchnl_ena;

    assign  qspi_wchnl_set      =   qspi_write_hit & spi_if_awvalid & spi_if_wvalid & spi_if_awready & spi_if_wready;
    assign  qspi_wchnl_clr      =   1'b1;

    wire    qspi_rchnl_r;
    wire    qspi_rchnl_nxt;
    wire    qspi_rchnl_set;
    wire    qspi_rchnl_ena;
    wire    qspi_rchnl_clr;
    
    assign  qspi_rchnl_set      =   qspi_req_vld & qspi_req_rdy & qspi_req_read;                                  
    assign  qspi_rchnl_clr      =   qspi_rsp_vld & qspi_rsp_rdy;
    assign  qspi_rchnl_ena      =   qspi_rchnl_set | qspi_rchnl_clr;
    assign  qspi_rchnl_nxt      =   qspi_rchnl_set | ~qspi_rchnl_clr;
    dfflr #(1) qspi_rchnl_dfflr(qspi_rchnl_ena, qspi_rchnl_nxt, qspi_rchnl_r, clk, rst_n);

    assign  qspi_req_vld        =   ~spi_flash_rchnl_r & ~spi_flash_wchnl_r & ~spi_flash_busy &(spi_if_awvalid & spi_if_wvalid & qspi_write_hit)
    assign  qspi_

endmodule
