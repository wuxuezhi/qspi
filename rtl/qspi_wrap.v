module qpsi_wrap #(
    parameter   DW = 32,
    parameter   AW = 32
)(
    input               aclk,
    input               aresetn,

    input [AW-1:0]      qspi_wrap_awaddr,
    input [2:0]         qspi_wrap_awprot,
    input               qspi_wrap_awvalid,
    output              qspi_wrap_awready,

    input [DW-1:0]      qspi_wrap_wdata,
    input [(DW>>3)-1:0] qspi_wrap_wstrb,
    input               qspi_wrap_wvalid,
    output              qspi_wrap_wready,

    output [1:0]        qspi_wrap_bresp,
    output              qspi_wrap_bvalid,
    input               qspi_wrap_bready,

    input               qspi_wrap_arvalid,
    output              qspi_wrap_arready,
    input [AW-1:0]      qspi_wrap_araddr,
    input [2:0]         qspi_wrap_arprot,

    output              qspi_wrap_rvalid,
    input               qspi_wrap_rready,
    output[DW-1:0]      qspi_wrap_rdata,
    output[1:0]         qspi_wrap_rresp,

    output              qspi_sck,
    output              qspi_csn,
    output              qspi_dq0_en,
    input               qspi_dq0_i,
    output              qspi_dq0_o,
    output              qspi_dq1_en,
    input               qspi_dq1_i,
    output              qspi_dq1_o,
    output              qspi_dq2_en,
    input               qspi_dq2_i,
    output              qspi_dq2_o,
    output              qspi_dq3_en,
    input               qspi_dq3_i,
    output              qspi_dq3_o,
);

    wire                clk     =   aclk;//alias
    wire                rst_n   =   aresetn;

    wire    [7:0]       qspi_config0_r;
    wire    [7:0]       qspi_config0_nxt;
    wire                qspi_config0_wen;

    dfflr #(8)  qspi_config0_dfflr(qspi_config0_wen, qspi_config0_nxt, qspi_config0_r, clk, rst_n);


    wire    [7:0]       qspi_config1_r;
    wire    [7:0]       qspi_config1_nxt;
    wire                qspi_config1_wen;

    dfflr #(8)  qspi_config1_dfflr(qspi_config1_wen, qspi_config1_nxt, qspi_config1_r, clk, rst_n);

    wire    [7:0]       qspi_data_r;
    wire    [7:0]       qspi_data_nxt;
    wire                qspi_data_wen;

    dfflr #(8)  qspi_data_dfflr(qspi_data_wen, qspi_data_nxt, qspi_data_r, clk, rst_n);


    wire    qspi_wrap_awchnl_hsked  =   qspi_wrap_awvalid & qspi_wrap_awready;

    wire    qspi_wrap_acc_addr      =   

    




endmodule
