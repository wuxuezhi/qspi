module spi_flash_ctrl #(
    parameter   DW = 128,
    parameter   AW = 32,
    parameter   IDW=8
)(
    input               aclk,
    input               aresetn,

    input [IDW-1:0]     s_awid,
    input [AW-1:0]      s_awaddr,
    input [7:0]         s_awlen,
    input [2:0]         s_awsize,
    input [1:0]         s_awburst,
    input               s_awlock,
    input [3:0]         s_awcache,
    input [2:0]         s_awprot,
    input               s_awvalid,
    output              s_awready,

    input [IDW-1:0]     s_wid,
    input [DW-1:0]      s_wdata,
    input [(DW/8)-1:0]  s_wstrb,
    input               s_wlast,
    input               s_wvalid,
    output              s_wready,

    output[IDW-1:0]     s_bid,
    output[1:0]         s_bresp,
    output              s_bvalid,
    input               s_bready,

    input [IDW-1:0]     s_arid,
    input [AW-1:0]      s_araddr,
    input [7:0]         s_arlen,
    input [2:0]         s_arsize,
    input [1:0]         s_arburst,
    input               s_arlock,
    input [3:0]         s_arcache,
    input [2:0]         s_arprot,
    input               s_arvalid,
    output              s_arready,

    output[IDW-1:0]     s_rid,
    output[DW-1:0]      s_rdata,
    output[1:0]         s_rresp,
    output              s_rlast,
    output              s_rvalid,
    input               s_rready,

    output              sck_o,
    output[3:0]         csn_o,
    output[3:0]         csn_en,

    output              sdo_en,
    output              sdo_o,
    input               sdo_i,

    output              sdi_en,
    output              sdi_o,
    input               sdi_i,

    output              holdn_en,
    output              holdn_o,
    input               holdn_i,

    output              wpn_en,
    output              wpn_o,
    input               wpn_i
);
    wire                clk         =   aclk;
    wire                rst_n       =   aresetn;

    wire [$clog2(DW>>3)-1:0]    byte_lane_idx;
    onehot_encoder #(DW>>3) byte_lane_enc(s_wstrb, byte_lane_idx);

    wire [7:0]  byte_lane[(DW>>3)-1:0];

    genvar i;
    generate
        for(i=0;i < (DW>>3); i=i+1) begin
            assign  byte_lane[i]        =   {8{s_wstrb[i]}} & s_wdata[i*8+7:i*8];
        end
    endgenerate
    

    //write address channel buf
    wire                aw_chnl_vld_r;
    wire                aw_chnl_vld_nxt;
    wire                aw_chnl_vld_set;
    wire                aw_chnl_vld_clr;
    wire                aw_chnl_vld_ena;

    assign              aw_chnl_vld_set     =   s_awvalid & s_awready;
    assign              aw_chnl_vld_ena     =   aw_chnl_vld_set | aw_chnl_vld_clr;
    assign              aw_chnl_vld_nxt     =   aw_chnl_vld_set | ~aw_chnl_vld_clr;
    dfflr #(1)  aw_chnl_vld_dfflr(aw_chnl_vld_ena, aw_chnl_vld_nxt, aw_chnl_vld_r, clk, rst_n);

    wire [AW-1:0]       aw_chnl_addr_r;
    wire [AW-1:0]       aw_chnl_addr_nxt    =   s_awaddr;
    dfflr #(AW) aw_chnl_addr_buf(aw_chnl_vld_ena, aw_chnl_addr_nxt, aw_chnl_addr_r, clk, rst_n);

    wire [IDW-1:0]      aw_chnl_id_r;
    wire [IDW-1:0]      aw_chnl_id_nxt      =   s_awid;

    dfflr #(IDW)    aw_chnl_id_buf(aw_chnl_vld_ena, aw_chnl_id_nxt, aw_chnl_id_r, clk, rst_n);

    wire [7:0]          aw_chnl_len_r;
    wire [7:0]          aw_chnl_len_nxt     =   s_awlen;

    dfflr #(8)      aw_chnl_len_buf(aw_chnl_vld_ena, aw_chnl_len_nxt, aw_chnl_len_r, clk, rst_n);

    wire [2:0]          aw_chnl_size_r;
    wire [2:0]          aw_chnl_size_nxt    =   s_awsize;

    dfflr #(3)      aw_chnl_size_buf(aw_chnl_vld_ena, aw_chnl_size_nxt, aw_chnl_size_r, clk, rst_n);

    wire [1:0]          aw_chnl_burst_r;
    wire [1:0]          aw_chnl_burst_nxt   =   s_awburst;

    dfflr #(2)      aw_chnl_burst_buf(aw_chnl_vld_ena, aw_chnl_burst_nxt, aw_chnl_burst_r, clk, rst_n);

    



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



    //interface
    wire                if_rreq_vld;
    wire                if_rreq_rdy;
    wire                if_wreq_vld;
    wire                if_wreq_rdy;

    assign              if_wreq_vld     =       s_wvalid & aw_chnl_vld_r;
    assign              if_wreq_rdy     =       ~spi_flash_reg_switch_qspi& spi_flash_awready & spi_flash_wready
                                               |spi_flash_reg_switch_qspi & qspi_if_req_rdy;

    assign              if_rreq_vld     =       s_arvalid;
    assign              if_rreq_rdy     =       spi_flash_reg_switch_qspi & qspi_if_req_rdy
                                               |~spi_flash_reg_switch_qspi& spi_flash_rready;

    wire [AW-1:0]       if_rreq_addr    =       s_araddr;
    wire [AW-1:0]       if_wreq_addr    =       {aw_chnl_addr_r[AW-1:$clog2(DW>>3)], byte_lane_idx};

    assign              aw_chnl_vld_clr =       if_wreq_vld & if_wreq_rdy;


    wire [IDW-1:0]      qspi_id_r;
    wire [IDW-1:0]      qspi_id_nxt;
    wire                qspi_id_ena;

    assign              qspi_id_ena     =       qspi_if_req_vld & qspi_if_req_rdy;
    assign              qspi_id_nxt     =       {IDW{qspi_if_req_read}} & s_arid
                                            |   {IDW{~qspi_if_req_read}}& s_awid;
    dfflr #(IDW)    qspi_id_dfflr(qspi_id_ena, qspi_id_nxt, qspi_id_r, clk, rst_n);

    wire [3:0]          qspi_addr_r;
    wire [3:0]          qspi_addr_nxt;
    wire                qspi_addr_ena;

    assign              qspi_addr_ena   =       qspi_if_req_vld & qspi_if_req_rdy;
    assign              qspi_addr_nxt   =       qspi_if_req_addr;

    dfflr #(4)          qspi_addr_dfflr(qspi_addr_ena, qspi_addr_nxt, qspi_addr_r, clk, rst_n);

    wire            qspi_read_r;
    wire            qspi_read_nxt;
    wire            qspi_read_ena;

    assign          qspi_read_ena       =   qspi_if_req_vld & qspi_if_req_rdy;
    assign          qspi_read_nxt       =   qspi_if_req_read;
    dfflr #(1)  qspi_read_dfflr(qspi_read_ena, qspi_read_nxt, qspi_read_r, clk, rst_n);





    assign          spi_flash_awid      =   aw_chnl_id_r;
    assign          spi_flash_awaddr    =   aw_chnl_addr_r;
    assign          spi_flash_awlen     =   aw_chnl_len_r;
    assign          spi_flash_awsize    =   aw_chnl_size_r;
    assign          spi_flash_awburst   =   aw_chnl_burst_r;
    assign          spi_flash_awlock    =   1'b0;
    assign          spi_flash_awcache   = 0;
    assign          spi_flash_awvalid   =   aw_chnl_vld_r & (~spi_flash_reg_switch_qspi | (if_wreq_addr[3:0] == 4'hf));

    assign          spi_flash_wdata     =   s_wdata;
    assign          spi_flash_wstrb     =   s_wstrb;
    assign          spi_flash_wlast     =   s_wlast;
    assign          spi_flash_wvalid    =   s_wvalid & aw_chnl_vld_r & (~spi_flash_reg_switch_qspi | (if_wreq_addr[3:0] == 4'hf));

    assign          spi_flash_bready    =   s_bready & ~spi_flash_reg_switch_qspi;

    assign          spi_flash_arid      =   s_arid;
    assign          spi_flash_araddr    =   if_rreq_addr;
    assign          spi_flash_arlen     =   s_arlen;
    assign          spi_flash_arsize    =   s_arsize;
    assign          spi_flash_arburst   =   s_arburst;
    assign          spi_flash_arvalid   =   s_arvalid & (~spi_flash_reg_switch_qspi | (if_rreq_addr[3:0] == 4'hf));

    assign          spi_flash_rready    =   s_rready & ~spi_flash_reg_switch_qspi;





    assign          qspi_if_req_vld     =   spi_flash_reg_switch_qspi & (
                                                                            aw_chnl_vld_r & s_wvalid & (if_wreq_addr[3:0] != 4'hf)
                                                                        |   s_arvalid * (if_rreq_addr[3:0] != 4'hf)
                                                                            );
    assign          qspi_if_req_read    =   ~aw_chnl_vld_r;
    
    assign          qspi_if_req_addr    =   ({4{qspi_if_req_read}} & if_rreq_addr[3:0])
                                           |({4{~qspi_if_req_read}}& if_wreq_addr[3:0]);
    assign          qspi_if_req_dat     =   byte_lane[byte_lane_idx];
    assign          qspi_if_rsp_rdy     =   qspi_read_r & ~spi_flash_rvalid & s_rready
                                           |~qspi_read_r& ~spi_flash_bvalid & s_bready;  

    assign          s_awready           =   ~aw_chnl_vld_r;
    assign          s_wready            =   aw_chnl_vld_r & (
                                                                spi_flash_reg_switch_qspi & qspi_if_req_rdy & ~spi_flash_busy
                                                               |~spi_flash_reg_switch_qspi& spi_flash_wready
                                                                );
    assign          s_bid               =   {IDW{spi_flash_reg_switch_qspi}} & qspi_id_r
                                           |{IDW{spi_flash_reg_switch_qspi}} & spi_flash_bid;
    assign          s_bresp             =   {2{spi_flash_reg_switch_qspi}} & 2'b00
                                           |{2{~spi_flash_reg_switch_qspi}}& spi_flash_bresp;
    assign          s_bvalid            =   spi_flash_reg_switch_qspi & qspi_if_rsp_vld
                                           |~spi_flash_reg_switch_qspi& spi_flash_bvalid;

    assign          s_arready           =   spi_flash_reg_switch_qspi & qspi_if_req_rdy
                                           |~spi_flash_reg_switch_qspi& spi_flash_arready;

    assign          s_rvalid            =   spi_flash_reg_switch_qspi & qspi_if_rsp_vld & qspi_read_r
                                           |~spi_flash_reg_switch_qspi& spi_flash_rvalid;
    assign          s_rid               =   {IDW{spi_flash_reg_switch_qspi}} & qspi_id_r
                                           |{IDW{~spi_flash_reg_switch_qspi}}& spi_flash_rid;
    assign          s_rdata             =   {DW{spi_flash_reg_switch_qspi}} & ({{DW-8{1'b0}}, qspi_if_rsp_dat} << qspi_addr_r)
                                           |{DW{~spi_flash_reg_switch_qspi}}& spi_flash_rdata;
    assign          s_rresp             =   {2{spi_flash_reg_switch_qspi}} & 2'b00
                                           |{2{~spi_flash_reg_switch_qspi}}& spi_flash_rresp;
    assign          s_rlast             =   spi_flash_reg_switch_qspi & 1'b1
                                           |~spi_flash_reg_switch_qspi& spi_flash_rlast;  


    assign          csn_en[0]           =   qspi_if_switch_qspi ? 1'b0 : spi_flash_csen[0];
    assign          csn_o[0]            =   qspi_if_switch_qspi ? qspi_if_csn : spi_flash_csn_o[0];

    assign          csn_en[1]           =   spi_flash_csen[1];
    assign          csn_o[1]            =   spi_flash_csn_o[1];

    assign          csn_en[2]           =   spi_flash_csen[2];
    assign          csn_o[2]            =   spi_flash_csn_o[2];

    assign          csn_en[3]           =   spi_flash_csen[3];
    assign          csn_o[3]            =   spi_flash_csn_o[3];

    assign          sdi_en              =   qspi_if_switch_qspi ? qspi_if_dq0_en : spi_flash_sdi_en;
    assign          sdi_o               =   qspi_if_switch_qspi ? qspi_if_dq0_o  : spi_flash_sdi_o;

    assign          sdo_en              =   qspi_if_switch_qspi ? qspi_if_dq1_en : spi_flash_sdo_en;
    assign          sdo_o               =   qspi_if_switch_qspi ? qspi_if_dq1_o  : spi_flash_sdo_o;

    assign          qspi_if_dq0_i       =   sdi_i;
    assign          qspi_if_dq1_i       =   sdo_i;
    assign          qspi_if_dq2_i       =   wpn_i;
    assign          qspi_if_dq3_i       =   holdn_i;                                                                                                   

    assign          sck_o               =   qspi_if_switch_qspi ? qspi_if_sck : spi_flash_sck;

    assign          spi_flash_sdi_i     =   sdi_i;
    assign          spi_flash_sdo_i     =   sdo_i;
    assign          spi_flash_hold_i    =   holdn_i;
    assign          spi_flash_wpn_i     =   wpn_i;
    
    assign          wpn_o               =   qspi_if_switch_qspi ? qspi_if_dq2_o : spi_flash_wpn_o;
    assign          wpn_en              =   qspi_if_switch_qspi ? qspi_if_dq2_en: spi_flash_wpn_en;
    assign          holdn_o             =   qspi_if_switch_qspi ? qspi_if_dq3_o : spi_flash_hold_o;
    assign          holdn_en            =   qspi_if_switch_qspi ? qspi_if_dq3_en: spi_flash_hold_en;





endmodule
