module sim_top();
    localparam  IDW = 8;
    localparam  DW  = 128;
    localparam  AW  = 32;


    reg             aclk;
    reg             aresetn;

    reg [IDW-1:0]   spi_if_awid;
    reg [AW-1:0]    spi_if_awaddr;
    reg [7:0]       spi_if_awlen;
    reg [2:0]       spi_if_awsize;
    reg [1:0]       spi_if_awburst;
    reg             spi_if_awlock;
    reg [2:0]       spi_if_awcache;
    reg             spi_if_awvalid;
    wire            spi_if_awready;

    reg [DW-1:0]    spi_if_wdata;
    reg [(DW/8)-1:0]spi_if_wstrb;
    reg             spi_if_wlast;
    reg             spi_if_wvalid;
    wire            spi_if_wready;


    wire[IDW-1:0]   spi_if_bid;
    wire[1:0]       spi_if_bresp;
    wire            spi_if_bvalid;
    reg             spi_if_bready;

    reg [IDW-1:0]   spi_if_arid;
    reg [AW-1:0]    spi_if_araddr;
    reg [7:0]       spi_if_arlen;
    reg [2:0]       spi_if_arsize;
    reg [1:0]       spi_if_arburst;
    reg             spi_if_arvalid;
    wire            spi_if_arready;

    wire[IDW-1:0]   spi_if_rid;
    wire[DW-1:0]    spi_if_rdata;
    wire[1:0]       spi_if_rresp;
    wire            spi_if_rlast;
    wire            spi_if_rvalid;
    reg             spi_if_rready;

    wire            spi_if_sck;

    wire[3:0]       spi_if_csn_en;
    wire[3:0]       spi_if_csn_o;
    reg [3:0]       spi_if_csn_i;

    wire            spi_if_sdo_en;
    wire            spi_if_sdo_o;
    reg             spi_if_sdo_i;

    wire            spi_if_sdi_en;
    wire            spi_if_sdi_o;
    reg             spi_if_sdi_i;




    spi_axi_if #(
        .DW(DW),
        .IDW(IDW),
        .AW(AW)
    ) uut_spi_axi_if(
        .aclk(aclk),
        .aresetn(aresetn),

        .spi_if_awid(spi_if_awid),
        .spi_if_awaddr(spi_if_awaddr),
        .spi_if_awlen(spi_if_awlen),
        .spi_if_awsize(spi_if_awsize),
        .spi_if_awburst(spi_if_awburst),
        .spi_if_awlock(spi_if_awlock),
        .spi_if_awcache(spi_if_awcache),
        .spi_if_awvalid(spi_if_awvalid),
        .spi_if_awready(spi_if_awready),

        .spi_if_wdata(spi_if_wdata),
        .spi_if_wstrb(spi_if_wstrb),
        .spi_if_wlast(spi_if_wlast),
        .spi_if_wvalid(spi_if_wvalid),
        .spi_if_wready(spi_if_wready),

        .spi_if_bid(spi_if_bid),
        .spi_if_bresp(spi_if_bresp),
        .spi_if_bvalid(spi_if_bvalid),
        .spi_if_bready(spi_if_bready),

        .spi_if_arid(spi_if_arid),
        .spi_if_araddr(spi_if_araddr),
        .spi_if_arlen(spi_if_arlen),
        .spi_if_arsize(spi_if_arsize),
        .spi_if_arburst(spi_if_arburst),
        .spi_if_arvalid(spi_if_arvalid),
        .spi_if_arready(spi_if_arready),

        .spi_if_rid(spi_if_rid),
        .spi_if_rdata(spi_if_rdata),
        .spi_if_rresp(spi_if_rresp),
        .spi_if_rlast(spi_if_rlast),
        .spi_if_rvalid(spi_if_rvalid),
        .spi_if_rready(spi_if_rready),

        .spi_if_sck(spi_if_sck),
        .spi_if_csn_en(spi_if_csn_en),
        .spi_if_csn_o(spi_if_csn_o),
        .spi_if_csn_i(spi_if_csn_i),

        .spi_if_sdo_en(spi_if_sdo_en),
        .spi_if_sdo_o(spi_if_sdo_o),
        .spi_if_sdo_i(spi_if_sdo_i),

        .spi_if_sdi_en(spi_if_sdi_en),
        .spi_if_sdi_o(spi_if_sdi_o),
        .spi_if_sdi_i(spi_if_sdi_i)
    );

    always begin
        #20;
        aclk = 1'b0;
        #20;
        aclk = 1'b1;
    end


    

endmodule