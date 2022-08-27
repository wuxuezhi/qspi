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
        .AW(AW),
        .QSPI_HADDR(24'h1fff03)
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

    initial begin
        aresetn = 1'b0;
 

        spi_if_awvalid  = 1'b0;
        spi_if_awid     = 8'd24;
        spi_if_awaddr   = 32'h1fff0300;
        spi_if_awlen    = 8'd0;
        spi_if_awsize   = 3'b000;
        spi_if_awburst  = 2'b00;
        spi_if_awlock   = 1'b0;
        spi_if_awcache  = 0;
        
        spi_if_wvalid   = 1'b0;
        spi_if_wdata    = 128'h00000000000000000000000001000000;
        spi_if_wstrb    = 16'd8;
        spi_if_wlast    = 1'b1;
        
        spi_if_bready   = 1'b0;

        spi_if_arid     = 8'd25;
        spi_if_araddr   = 32'd0;
        spi_if_arlen    = 8'd0;
        spi_if_arsize   = 3'd0;
        spi_if_arburst  = 2'b00;
        spi_if_arvalid  = 1'b0;

        spi_if_rready   = 1'b0;
        #200;
        aresetn         = 1'b1;
        #200;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_bready   = 1'b1;
        
        #40;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid   = 1'b0;
        #400;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_wstrb    = 16'd2;
        spi_if_wdata    = 128'd0;
        #40;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid   = 1'b0;
        #400;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_wstrb    = 16'd4;
        spi_if_wdata    = 128'h000000000000000000000000000b0000;
        #40;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid   = 1'b0;
        #40;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_wdata    = 128'h00000000000000000000000000ff0000;
        #600;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid    = 1'b0;
        #200;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_wstrb    = 16'd1;
        spi_if_wdata    = 128'd32;
        #600;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid   = 1'b0;
        #40;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_wstrb    = 16'd4;
        spi_if_wdata    = 128'h00000000000000000000000000050000;
        spi_if_sdi_i    = 1'b1;
        spi_if_sdo_i    = 1'b1;
        #40;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid   = 1'b0;
        #600;
        spi_if_awvalid  = 1'b1;
        spi_if_wvalid   = 1'b1;
        spi_if_wstrb    = 16'd1;
        spi_if_wdata    = 128'd0;
        #600;
        spi_if_awvalid  = 1'b0;
        spi_if_wvalid   = 1'b0;
        spi_if_arvalid  = 1'b1;
        spi_if_araddr   = 32'h1fff0302;
        spi_if_rready   = 1'b1;       
        
        
        //SWITCH WIRTE 8'h01;

    end


    always begin
        #20;
        aclk = 1'b0;
        #20;
        aclk = 1'b1;
    end


    

endmodule
