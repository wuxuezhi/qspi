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

    output [IDW-1:0]    spi_if_bid,
    output [1:0]        spi_if_bresp,
    output              spi_if_bvalid,
    input               spi_if_bready
);
    

endmodule
