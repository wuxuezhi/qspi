module spi_axi_if #(
    parameter DW = 128,
    parameter AW = 32,
    parameter IDW = 6
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
    output              spi_if_sck,

    output[3:0]         spi_if_csn_en,
    output[3:0]         spi_if_csn_o,

    output              spi_if_sdo_en,
    output              spi_if_sdo_o,
    input               spi_if_sdo_i,

    output              spi_if_sdi_en,
    output              spi_if_sdi_o,
    input               spi_if_sdi_i,

    output              spi_if_holdn_en,
    output              spi_if_holdn_o,
    input               spi_if_holdn_i,

    output              spi_if_wpn_en,
    output              spi_if_wpn_o,
    input               spi_if_wpn_i

);


    wire                clk                 =   aclk;//alias
    wire                rst_n               =   aresetn;

    wire                aw_w_vld_sync       =   spi_if_awvalid & spi_if_wvalid;

    wire [AW-1:0]          if_wreq_addr;
    wire [$clog2(DW>>3)-1:0]    byte_lane_idx;
    onehot_encoder #(DW>>3) byte_lane_enc(spi_if_wstrb, byte_lane_idx);

    wire [7:0]  byte_lane[(DW>>3)-1:0];

    genvar i;
    generate
        for(i=0;i < (DW>>3); i=i+1) begin
            assign  byte_lane[i]        =   {8{spi_if_wstrb[i]}} & spi_if_wdata[i*8+7:i*8];
        end
    endgenerate
    

    assign              if_wreq_addr        =   {spi_if_awaddr[AW-1:$clog2(DW>>3)], byte_lane_idx};

    wire [AW-1:0]       if_rreq_addr        =   spi_if_araddr;




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

    wire [3:0]      spi_flash_csen;
    wire [3:0]      spi_flash_csn_o;
    wire            spi_flash_sdo_en;
    wire            spi_flash_sdo_o;
    wire            spi_flash_sdo_i;
    wire            spi_flash_sdi_en;
    wire            spi_flash_sdi_o;
    wire            spi_flash_sdi_i;
    wire            spi_flash_sck;
    wire            spi_flash_hold_en;
    wire            spi_flash_hold_o;
    wire            spi_flash_hold_i;
    wire            spi_flash_wpn_en;
    wire            spi_flash_wpn_o;
    wire            spi_flash_wpn_i;
    wire            spi_flash_busy;
    wire            spi_flash_reg_switch_qspi;





    spi_flash #(
        .DW(DW),
        .AW(AW),
        .IDW(IDW)
    ) u_spi_flash(
        .spi_flash_aclk(aclk),
        .spi_flash_aresetn(aresetn),

        .spi_flash_awid(spi_flash_awid),
        .spi_flash_awaddr(spi_flash_awaddr),
        .spi_flash_awlen(spi_flash_awlen),
        .spi_flash_awsize(spi_flash_awsize),
        .spi_flash_awburst(spi_flash_awburst),
        .spi_flash_awlock(spi_flash_awlock),
        .spi_flash_awcache(spi_flash_awcache),
        .spi_flash_awvalid(spi_flash_awvalid),
        .spi_flash_awready(spi_flash_awready),
        
        .spi_flash_wdata(spi_flash_wdata),
        .spi_flash_wstrb(spi_flash_wstrb),
        .spi_flash_wlast(spi_flash_wlast),
        .spi_flash_wvalid(spi_flash_wvalid),
        .spi_flash_wready(spi_flash_wready),
        
        .spi_flash_bid(spi_flash_bid),
        .spi_flash_bresp(spi_flash_bresp),
        .spi_flash_bvalid(spi_flash_bvalid),
        .spi_flash_bready(spi_flash_bready),

        .spi_flash_arid(spi_flash_arid),
        .spi_flash_araddr(spi_flash_araddr),
        .spi_flash_arlen(spi_flash_arlen),
        .spi_flash_arsize(spi_flash_arsize),
        .spi_flash_arburst(spi_flash_arburst),
        .spi_flash_arvalid(spi_flash_arvalid),
        .spi_flash_arready(spi_flash_arready),

        .spi_flash_rid(spi_flash_rid),
        .spi_flash_rdata(spi_flash_rdata),
        .spi_flash_rresp(spi_flash_rresp),
        .spi_flash_rlast(spi_flash_rlast),
        .spi_flash_rvalid(spi_flash_rvalid),
        .spi_flash_rready(spi_flash_rready),
        
        .spi_flash_csen(spi_flash_csen),
        .spi_flash_csn_o(spi_flash_csn_o),
        .spi_flash_sdo_en(spi_flash_sdo_en),
        .spi_flash_sdo_o(spi_flash_sdo_o),
        .spi_flash_sdo_i(spi_flash_sdo_i),
        .spi_flash_sdi_en(spi_flash_sdi_en),
        .spi_flash_sdi_o(spi_flash_sdi_o),
        .spi_flash_sdi_i(spi_flash_sdi_i),
        .spi_flash_sck(spi_flash_sck),
        .spi_flash_hold_en(spi_flash_hold_en),
        .spi_flash_hold_o(spi_flash_hold_o),
        .spi_flash_hold_i(spi_flash_hold_i),
        .spi_flash_wpn_en(spi_flash_wpn_en),
        .spi_flash_wpn_o(spi_flash_wpn_o),
        .spi_flash_wpn_i(spi_flash_wpn_i),
        .spi_flash_busy(spi_flash_busy),

        .spi_flash_reg_switch_qspi(spi_flash_reg_switch_qspi)
    );


    

    wire            qspi_if_req_vld;
    wire            qspi_if_req_rdy;
    wire [3:0]      qspi_if_req_addr;
    wire            qspi_if_req_read;
    wire [7:0]      qspi_if_req_dat;

    wire            qspi_if_rsp_vld;
    wire            qspi_if_rsp_rdy;
    wire [7:0]      qspi_if_rsp_dat;

    wire            qspi_if_switch_qspi;

    wire            qspi_if_sck;
    wire            qspi_if_csn;
    wire            qspi_if_dq0_en;
    wire            qspi_if_dq0_o;
    wire            qspi_if_dq0_i;
    wire            qspi_if_dq1_en;
    wire            qspi_if_dq1_o;
    wire            qspi_if_dq1_i;
    wire            qspi_if_dq2_en;
    wire            qspi_if_dq2_o;
    wire            qspi_if_dq2_i;
    wire            qspi_if_dq3_en;
    wire            qspi_if_dq3_o;
    wire            qspi_if_dq3_i;

    qspi_wrap qspi_if(
        .qspi_if_req_vld(qspi_if_req_vld),
        .qspi_if_req_rdy(qspi_if_req_rdy),
        .qspi_if_req_addr(qspi_if_req_addr),
        .qspi_if_req_read(qspi_if_req_read),
        .qspi_if_req_dat(qspi_if_req_dat),

        .qspi_if_rsp_vld(qspi_if_rsp_vld),
        .qspi_if_rsp_rdy(qspi_if_rsp_rdy),
        .qspi_if_rsp_dat(qspi_if_rsp_dat),

        .qspi_if_switch_qspi(qspi_if_switch_qspi),

        .qspi_if_sck(qspi_if_sck),
        .qspi_if_csn(qspi_if_csn),
        .qspi_if_dq0_en(qspi_if_dq0_en),
        .qspi_if_dq0_o(qspi_if_dq0_o),
        .qspi_if_dq0_i(qspi_if_dq0_i),
        .qspi_if_dq1_en(qspi_if_dq1_en),
        .qspi_if_dq1_o(qspi_if_dq1_o),
        .qspi_if_dq1_i(qspi_if_dq1_i),
        .qspi_if_dq2_en(qspi_if_dq2_en),
        .qspi_if_dq2_o(qspi_if_dq2_o),
        .qspi_if_dq2_i(qspi_if_dq2_i),
        .qspi_if_dq3_en(qspi_if_dq3_en),
        .qspi_if_dq3_o(qspi_if_dq3_o),
        .qspi_if_dq3_i(qspi_if_dq3_i),

        .clk(aclk),
        .rst_n(aresetn)
    );



    wire [IDW-1:0]  qspi_id_r;
    wire [IDW-1:0]  qspi_id_nxt;
    wire            qspi_id_ena;
    
    assign          qspi_id_ena         =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_id_nxt         =   {IDW{qspi_if_req_read}} & spi_if_arid
                                        |   {IDW{~qspi_if_req_read}}& spi_if_awid;
    dfflr #(IDW)    qspi_id_dfflr(qspi_id_ena, qspi_id_nxt, qspi_id_r, clk, rst_n);

    wire [3:0]      qspi_addr_r;
    wire [3:0]      qspi_addr_nxt;
    wire            qspi_addr_ena;

    assign          qspi_addr_ena       =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_addr_nxt       =   qspi_if_req_addr;

    dfflr #(4)      qspi_addr_dfflr(qspi_addr_ena, qspi_addr_nxt, qspi_addr_r, clk, rst_n);

    wire            qspi_read_r;
    wire            qspi_read_nxt;
    wire            qspi_read_ena;

    assign          qspi_read_ena       =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_read_nxt       =   qspi_if_req_read;
    dfflr #(1)  qspi_read_dfflr(qspi_read_ena, qspi_read_nxt, qspi_read_r, clk, rst_n);




    assign          spi_flash_awid      =   spi_if_awid;
    assign          spi_flash_awaddr    =   spi_if_awaddr;
    assign          spi_flash_awlen     =   spi_if_awlen;
    assign          spi_flash_awsize    =   spi_if_awsize;
    assign          spi_flash_awburst   =   spi_if_awburst;
    assign          spi_flash_awlock    =   spi_if_awlock;
    assign          spi_flash_awcache   =   spi_if_awcache;
    assign          spi_flash_awvalid   =   aw_w_vld_sync & (
                                                                ~spi_flash_reg_switch_qspi 
                                                               |(if_wreq_addr[3:0] == 4'hf) 
                                                               );
    
    assign          spi_flash_wdata     =   spi_if_wdata;
    assign          spi_flash_wstrb     =   spi_if_wstrb;
    assign          spi_flash_wlast     =   spi_if_wlast;
    assign          spi_flash_wvalid    =   aw_w_vld_sync & (
                                                                ~spi_flash_reg_switch_qspi
                                                               |(if_wreq_addr[3:0] == 4'hf)
                                                                );
    assign          spi_flash_bready    =   spi_if_bready & ~spi_flash_reg_switch_qspi;

    assign          spi_flash_arid      =   spi_if_arid;
    assign          spi_flash_araddr    =   if_rreq_addr;    
    assign          spi_flash_arlen     =   spi_if_arlen;
    assign          spi_flash_arsize    =   spi_if_arsize;
    assign          spi_flash_arburst   =   spi_if_arburst;
    assign          spi_flash_arvalid   =   spi_if_arvalid & (~spi_flash_reg_switch_qspi | (if_rreq_addr[3:0] == 4'hf));

    assign          spi_flash_rready    =   spi_if_rready & ~spi_flash_reg_switch_qspi;


    assign          qspi_if_req_vld     =   (aw_w_vld_sync & (if_wreq_addr[3:0] != 4'hf) | spi_if_arvalid & (if_rreq_addr[3:0] != 4'hf)) & spi_flash_reg_switch_qspi;
    assign          qspi_if_req_read    =   ~aw_w_vld_sync;

    assign          qspi_if_req_addr    =   {4{qspi_if_req_read}} & if_rreq_addr[3:0]
                                           |{4{~qspi_if_req_read}}& if_wreq_addr[3:0];

    assign          qspi_if_req_dat     =   byte_lane[byte_lane_idx];
    assign          qspi_if_rsp_rdy     =   qspi_read_r & ~spi_flash_rvalid & spi_if_rready
                                           |~qspi_read_r & ~spi_flash_bvalid & spi_if_bready;

    assign          spi_if_awready      =   aw_w_vld_sync & (
                                                                spi_flash_reg_switch_qspi & qspi_if_req_rdy & ~spi_flash_busy
                                                               |~spi_flash_reg_switch_qspi& spi_flash_awready
                                                                );
    assign          spi_if_wready       =   aw_w_vld_sync & (
                                                                spi_flash_reg_switch_qspi & qspi_if_req_rdy & ~spi_flash_busy
                                                               |~spi_flash_reg_switch_qspi& spi_flash_wready
                                                                );
    assign          spi_if_bid          =   {IDW{spi_flash_reg_switch_qspi}} & qspi_id_r
                                           |{IDW{spi_flash_reg_switch_qspi}} & spi_flash_bid;
    assign          spi_if_bresp        =   {2{spi_flash_reg_switch_qspi}} & 2'b00
                                           |{2{~spi_flash_reg_switch_qspi}}& spi_flash_bresp;
    assign          spi_if_bvalid       =   spi_flash_reg_switch_qspi & qspi_if_rsp_vld
                                           |~spi_flash_reg_switch_qspi& spi_flash_bvalid;

    assign          spi_if_arready      =   spi_flash_reg_switch_qspi & qspi_if_req_rdy
                                           |~spi_flash_reg_switch_qspi& spi_flash_arready;

    assign          spi_if_rvalid       =   spi_flash_reg_switch_qspi & qspi_if_rsp_vld & qspi_read_r
                                           |~spi_flash_reg_switch_qspi& spi_flash_rvalid;
    assign          spi_if_rid          =   {IDW{spi_flash_reg_switch_qspi}} & qspi_id_r
                                           |{IDW{~spi_flash_reg_switch_qspi}}& spi_flash_rid;
    assign          spi_if_rdata        =   {DW{spi_flash_reg_switch_qspi}} & ({{DW-8{1'b0}}, qspi_if_rsp_dat} << qspi_addr_r)
                                           |{DW{~spi_flash_reg_switch_qspi}}& spi_flash_rdata;
    assign          spi_if_rresp        =   {2{spi_flash_reg_switch_qspi}} & 2'b00
                                           |{2{~spi_flash_reg_switch_qspi}}& spi_flash_rresp;
    assign          spi_if_rlast        =   spi_flash_reg_switch_qspi & 1'b1
                                           |~spi_flash_reg_switch_qspi& spi_flash_rlast;
    




    assign          spi_if_csn_en[0]    =   qspi_if_switch_qspi ? 1'b1 : spi_flash_csen[0];
    assign          spi_if_csn_o[0]     =   qspi_if_switch_qspi ? qspi_if_csn : spi_flash_csn_o[0];

    assign          spi_if_csn_en[1]    =   spi_flash_csen[1];
    assign          spi_if_csn_o[1]     =   spi_flash_csn_o[1];

    assign          spi_if_csn_en[2]    =   spi_flash_csen[2];
    assign          spi_if_csn_o[2]     =   spi_flash_csn_o[2];
    
    assign          spi_if_csn_en[3]    =   spi_flash_csen[3];
    assign          spi_if_csn_o[3]     =   spi_flash_csn_o[3];

    assign          spi_if_sdi_en       =   qspi_if_switch_qspi ? qspi_if_dq0_en : spi_flash_sdi_en;
    assign          spi_if_sdi_o        =   qspi_if_switch_qspi ? qspi_if_dq0_o  : spi_flash_sdi_o;

    assign          spi_if_sdo_en       =   qspi_if_switch_qspi ? qspi_if_dq1_en : spi_flash_sdo_en;
    assign          spi_if_sdo_o        =   qspi_if_switch_qspi ? qspi_if_dq1_o  : spi_flash_sdo_o;


    assign          qspi_if_dq0_i       =   spi_if_sdi_i;

    assign          qspi_if_dq1_i       =   spi_if_sdo_i;

    assign          qspi_if_dq2_i       =   spi_if_wpn_i;
    
    assign          qspi_if_dq3_i       =   spi_if_holdn_i;

    assign          spi_if_sck          =   qspi_if_switch_qspi ? qspi_if_sck     : spi_flash_sck;

    assign          spi_flash_rready    =   spi_if_rready & ~qspi_if_switch_qspi;

    assign          spi_flash_sdi_i     =   spi_if_sdi_i;

    assign          spi_flash_sdo_i     =   spi_if_sdo_i;

    assign          spi_flash_hold_i    =   spi_if_holdn_i;

    assign          spi_flash_wpn_i     =   spi_if_wpn_i;

    assign          spi_if_wpn_o        =   qspi_if_switch_qspi ? qspi_if_dq2_o : spi_flash_wpn_o;

    assign          spi_if_wpn_en       =   qspi_if_switch_qspi ? qspi_if_dq2_en: spi_flash_wpn_en;

    assign          spi_if_holdn_o      =   qspi_if_switch_qspi ? qspi_if_dq3_o : spi_flash_hold_o;

    assign          spi_if_holdn_en     =   qspi_if_switch_qspi ? qspi_if_dq3_en: spi_flash_hold_en;
                                                                                                                                       





    endmodule
