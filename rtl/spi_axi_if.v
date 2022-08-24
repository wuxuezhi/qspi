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
    output              spi_if_sck,

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

    wire [3:0]      spi_flash_csen;
    wire [3:0]      spi_flash_csn_o;
    wire [3:0]      spi_flash_csn_i;
    wire            spi_flash_sdo_en;
    wire            spi_flash_sdo_o;
    wire            spi_flash_sdo_i;
    wire            spi_flash_sdi_en;
    wire            spi_flash_sdi_o;
    wire            spi_flash_sdi_i;
    wire            spi_flash_sck;



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
        .spi_flash_csn_i(spi_flash_csn_i),
        .spi_flash_sdo_en(spi_flash_sdo_en),
        .spi_flash_sdo_o(spi_flash_sdo_o),
        .spi_flash_sdo_i(spi_flash_sdo_i),
        .spi_flash_sdi_en(spi_flash_sdi_en),
        .spi_flash_sdi_o(spi_flash_sdi_o),
        .spi_flash_sdi_i(spi_flash_sdi_i),
        .spi_flash_sck(spi_flash_sck),

        .spi_flash_busy(spi_flash_busy)
    );



    wire            aw_hit_qspi         =   (spi_if_awaddr[AW-1:8] == QSPI_HADDR);
    wire            ar_hit_qspi         =   (spi_if_araddr[AW-1:8] == QSPI_HADDR);

    //SPI FLASH
    assign          spi_flash_awaddr    =   spi_if_awaddr;
    assign          spi_flash_awid      =   spi_if_awid;
    assign          spi_flash_awlen     =   spi_if_awlen;
    assign          spi_flash_awsize    =   spi_if_awsize;
    assign          spi_flash_awburst   =   spi_if_awburst;
    assign          spi_flash_awlock    =   spi_if_awlock;
    assign          spi_flash_awcache   =   spi_if_awcache;
    assign          spi_flash_awvalid   =   spi_if_awvalid & ~aw_hit_qspi;

    wire            spi_flash_awchnl_r;
    wire            spi_flash_awchnl_nxt;
    wire            spi_flash_awchnl_set;
    wire            spi_flash_awchnl_clr;
    wire            spi_flash_awchnl_ena;
    
    assign          spi_flash_awchnl_set=   spi_flash_awvalid & spi_flash_awready;
    assign          spi_flash_awchnl_clr=   spi_flash_bvalid  & spi_flash_bready;
    assign          spi_flash_awchnl_ena=   spi_flash_awchnl_set | spi_flash_awchnl_clr;
    assign          spi_flash_awchnl_nxt=   spi_flash_awchnl_set |~spi_flash_awchnl_clr;
    dfflr #(1)  spi_flash_awchnl_dfflr(spi_flash_awchnl_ena, spi_flash_awchnl_nxt, spi_flash_awchnl_r, clk, rst_n);

    


    assign          spi_flash_wdata     =   spi_if_wdata;
    assign          spi_flash_wstrb     =   spi_if_wstrb;
    assign          spi_flash_wlast     =   spi_if_wlast;
    assign          spi_flash_wvalid    =   spi_flash_awchnl_r & spi_if_wvalid;

    assign          spi_flash_bready    =   spi_if_bready;

    





    assign          spi_flash_arid      =   spi_if_arid;
    assign          spi_flash_araddr    =   spi_if_araddr;
    assign          spi_flash_arlen     =   spi_if_arlen;
    assign          spi_flash_arsize    =   spi_if_arsize;
    assign          spi_flash_arburst   =   spi_if_arburst;
    assign          spi_flash_arvalid   =   spi_if_arvalid;

    wire [IDW-1:0]  qspi_id_r;
    wire [IDW-1:0]  qspi_id_nxt;
    wire            qspi_id_ena;
    
    assign          qspi_id_ena         =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_id_nxt         =   {IDW{qspi_if_req_read}} & spi_if_arid
                                        |   {IDW{~qspi_if_req_read}}& spi_if_awid;
    dfflr #(IDW)    qspi_id_dfflr(qspi_id_ena, qspi_id_nxt, qspi_id_r, clk, rst_n);

    wire [2:0]      qspi_addr_r;
    wire [2:0]      qspi_addr_nxt;
    wire            qspi_addr_ena;

    assign          qspi_addr_ena       =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_addr_nxt       =   qspi_if_req_addr;

    dfflr #(3)      qspi_addr_dfflr(qspi_addr_ena, qspi_addr_nxt,qspi_addr_r, clk, rst_n);

    wire            qspi_read_r;
    wire            qspi_read_nxt;
    wire            qspi_read_ena;

    assign          qspi_read_ena       =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_read_nxt       =   qspi_if_req_read;
    dfflr #(1)  qspi_read_dfflr(qspi_read_ena, qspi_read_nxt, qspi_read_r, clk, rst_n);


    wire            qspi_if_req_vld;
    wire            qspi_if_req_rdy;
    wire [2:0]      qspi_if_req_addr;
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

    assign          qspi_if_req_vld     =   ~spi_flash_busy & (spi_if_awvalid & aw_hit_qspi & spi_if_wvalid | spi_if_arvalid & ar_hit_qspi);
    assign          qspi_if_req_addr    =   spi_if_awvalid & aw_hit_qspi & spi_if_wvalid ? spi_if_awaddr[2:0] : spi_if_araddr[2:0];
    assign          qspi_if_req_read    =   ~(spi_if_awvalid & aw_hit_qspi & spi_if_wvalid);





    wire [7:0]  byte_lane[(DW>>3)-1:0];

    genvar i;
    generate
        for(i=0;i < (DW>>3); i=i+1) begin
            assign  byte_lane[i]        =   {8{spi_if_wstrb[i]}} & spi_if_wdata[i*8+7:i*8];
        end
    endgenerate

    wire [$clog2(DW>>3)-1:0]            byte_lane_idx;
    onehot_encoder #(DW>>3) byte_lane_enc(spi_if_wstrb, byte_lane_idx);

    assign          qspi_if_req_dat     =   byte_lane[byte_lane_idx];
    assign          qspi_if_rsp_rdy     =   qspi_read_r & ~spi_flash_rvalid & spi_if_rready
                                        |   ~qspi_read_r& ~spi_flash_bvalid & spi_if_bready;



    assign          spi_if_awready      =   ~aw_hit_qspi ? spi_flash_awready : spi_if_wvalid & spi_if_awvalid & qspi_if_req_rdy;
    assign          spi_if_wready       =   spi_flash_awchnl_r ? spi_flash_wready : spi_if_wvalid & spi_if_awvalid & qspi_if_req_rdy;

    assign          spi_if_bid          =   spi_flash_awchnl_r ? spi_flash_bid : qspi_id_r;
    assign          spi_if_bresp        =   spi_flash_awchnl_r ? spi_flash_bresp : 2'b00;
    assign          spi_if_bvalid       =   spi_flash_awchnl_r ? spi_flash_bvalid:qspi_if_rsp_vld;
    
    assign          spi_if_arready      =   ~ar_hit_qspi ? spi_flash_arready : qspi_if_req_rdy;

    assign          spi_if_rvalid       =   spi_flash_rvalid | qspi_if_rsp_vld & qspi_read_r;
    assign          spi_if_rid          =   spi_flash_rvalid ? spi_flash_rid : qspi_id_r;
    assign          spi_if_rdata        =   spi_flash_rvalid ? spi_flash_rdata:{{DW-8{1'b0}},qspi_if_rsp_dat} << qspi_addr_r;
    assign          spi_if_rresp        =   spi_flash_rvalid ? spi_flash_rresp: 2'b00;
    assign          spi_if_rlast        =   spi_flash_rvalid ? spi_flash_rlast: 1'b1;



    assign          spi_if_csn_en[0]    =   qspi_if_switch_qspi ? 1'b1 : spi_flash_csen[0];
    assign          spi_if_csn_o[0]     =   qspi_if_switch_qspi ? qspi_if_csn : spi_flash_csn_o[0];

    assign          spi_if_csn_en[1]    =   spi_flash_csen[1];
    assign          spi_if_csn_o[1]     =   spi_flash_csn_o[1];

    assign          spi_if_csn_en[2]    =   qspi_if_switch_qspi ? qspi_if_dq2_en : spi_flash_csen[2];
    assign          spi_if_csn_o[2]     =   qspi_if_switch_qspi ? qspi_if_dq2_o  : spi_flash_csn_o[2];
    
    assign          spi_if_csn_en[3]    =   qspi_if_switch_qspi ? qspi_if_dq3_en : spi_flash_csen[3];
    assign          spi_if_csn_o[3]     =   qspi_if_switch_qspi ? qspi_if_dq3_o  : spi_flash_csn_o[3];

    assign          spi_if_sdi_en       =   qspi_if_switch_qspi ? qspi_if_dq0_en : spi_flash_sdi_en;
    assign          spi_if_sdi_o        =   qspi_if_switch_qspi ? qspi_if_dq0_o  : spi_flash_sdi_o;

    assign          spi_if_sdo_en       =   qspi_if_switch_qspi ? qspi_if_dq1_en : spi_flash_sdo_en;
    assign          spi_if_sdo_o        =   qspi_if_switch_qspi ? qspi_if_dq1_o  : spi_flash_sdo_o;

    assign          spi_flash_csn_i     =   spi_if_csn_i;

    assign          qspi_if_dq0_i       =   spi_if_sdi_i;

    assign          qspi_if_dq1_i       =   spi_if_sdo_i;

    assign          qspi_if_dq2_i       =   spi_if_csn_i[2];
    
    assign          qspi_if_dq3_i       =   spi_if_csn_i[3];

    assign          spi_if_sck          =   qspi_if_switch_qspi ? qspi_if_sck     : spi_flash_sck;

    assign          spi_flash_rready    =   spi_if_rready & ~qspi_if_switch_qspi;

    assign          spi_flash_sdi_i     =   spi_if_sdi_i;

    assign          spi_flash_sdo_i     =   spi_if_sdo_i;

endmodule
