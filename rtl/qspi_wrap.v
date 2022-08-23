module qspi_wrap(
    input               qspi_if_req_vld,
    output              qspi_if_req_rdy,
    input   [2:0]       qspi_if_req_addr,
    input               qspi_if_req_read,
    input   [7:0]       qspi_if_req_dat,

    output              qspi_if_rsp_vld,
    input               qspi_if_rsp_rdy,
    output  [7:0]       qspi_if_rsp_dat,

    output              qspi_if_sck,
    output              qspi_if_csn,
    output              qspi_if_dq0_en,
    input               qspi_if_dq0_i,
    output              qspi_if_dq0_o,
    output              qspi_if_dq1_en,
    input               qspi_if_dq1_i,
    output              qspi_if_dq1_o,
    output              qspi_if_dq2_en,
    input               qspi_if_dq2_i,
    output              qspi_if_dq2_o,
    output              qspi_if_dq3_en,
    input               qspi_if_dq3_i,
    output              qspi_if_dq3_o,

    input               clk,
    input               rst_n
);
    
    

    wire    [7:0]       qspi_config0_r;
    wire    [7:0]       qspi_config0_nxt;
    wire                qspi_config0_wen;

    assign              qspi_config0_nxt    =   qspi_if_req_dat;

    dfflr #(8)  qspi_conf    assign          qspi_req_vldig0_dfflr(qspi_config0_wen, qspi_config0_nxt, qspi_config0_r, clk, rst_n);


    wire    [7:0]       qspi_config1_r;
    wire    [7:0]       qspi_config1_nxt;
    wire                qspi_config1_wen;

    assign              qspi_config1_nxt    =   qspi_if_req_dat;

    dfflr #(8)  qspi_config1_dfflr(qspi_config1_wen, qspi_config1_nxt, qspi_config1_r, clk, rst_n);




    wire    qspi_config0_sel    =   (qspi_if_req_addr == 3'b000);
    wire    qspi_config1_sel    =   (qspi_if_req_addr == 3'b001);
    wire    qspi_data_sel       =   (qspi_if_req_addr == 3'b010);

    wire    qspi_if_req_hsked   =   qspi_if_req_vld & qspi_if_req_rdy;




    assign  qspi_config0_wen    =   qspi_config0_sel & qspi_if_req_hsked;

    assign  qspi_config1_wen    =   qspi_config1_sel & qspi_if_req_hsked;

    //qspi engine
    wire        qspi_req_vld;
    wire        qspi_req_rdy;
    wire        qspi_req_read;
    wire [7:0]  qspi_req_dat;
    wire        qspi_dummy;
    wire [1:0]  qspi_type;

    wire        qspi_busy;

    wire        qspi_rsp_vld;
    wire        qspi_rsp_rdy;
    wire [7:0]  qspi_rsp_dat;

    assig`ifdef REG_MUXn      qspi_if_req_rdy =   qspi_data_sel   ? qspi_req_rdy : 1'b1;
    assign      qspi_req_vld    =   qspi_if_req_vld & qspi_data_sel;
    assign      qspi_req_read   =   qspi_if_req_read;
    assign      qspi_dummy      =   qspi_config0_r[5];
    assign      qspi_type       =   qspi_config0_r[4:3];
    assign      qspi_req_dat    =   qspi_if_req_dat;
    //record
    wire        qspi_read_tr_r;
    wire        qspi_read_tr_nxt;
    wire        qspi_read_tr_ena;
    wire        qspi_read_tr_set;
    wire        qspi_read_tr_clr;

    assign      qspi_read_tr_set    =   qspi_if_req_hsked & qspi_data_sel & qspi_if_req_read;
    assign      qspi_read_tr_clr    =   qspi_rsp_vld & qspi_rsp_rdy;
    assign      qspi_read_tr_ena    =   qspi_read_tr_set | qspi_read_tr_clr;
    assign      qspi_read_tr_nxt    =   qspi_read_tr_set | ~qspi_read_tr_clr;
    dfflr #(1)  qspi_read_tr_dfflr(qspi_read_tr_ena, qspi_read_tr_nxt, qspi_read_tr_r, clk, rst_n);

    

    wire [1:0]  qspi_param_mode;
    wire [3:0]  qspi_param_div;
    wire        qspi_param_duxen;

    assign      qspi_param_mode =   qspi_config0_r[7:6];
    assign      qspi_param_div  =   qspi_config1_r[7:4];
    assign      qspi_param_duxen=   qspi_config0_r[2];


    qspi u_qspi(
        .i_qspi_req_vld(qspi_req_vld),
        .i_qspi_req_rdy(qspi_req_rdy),
        .i_qspi_req_read(qspi_req_read),
        .i_qspi_dat(qspi_req_dat),
        .i_qspi_dummy(qspi_dummy),
        .i_qspi_type(qspi_type),

        .o_qspi_rsp_vld(qspi_rsp_vld),
        .o_qspi_rsp_rdy(qspi_rsp_vld),
        .o_qspi_rsp_dat(qspi_rsp_dat),

        .qspi_param_mode(qspi_param_mode),
        .qspi_param_div(qspi_param_div),
        .qspi_param_duxen(qspi_param_duxen),

        .qspi_busy(qspi_busy),

        .qspi_sck(qspi_if_sck),
        .qspi_dq0_en(qspi_if_dq0_en),
        .qspi_dq0_o(qspi_if_dq0_o),
        .qspi_dq0_i(qspi_if_dq0_i),
        .qspi_dq1_en(qspi_if_dq1_en),
        .qspi_dq1_o(qspi_if_dq1_o),
        .qspi_dq1_i(qspi_if_dq1_i),
        .qspi_dq2_en(qspi_if_dq2_en),
        .qspi_dq2_o(qspi_if_dq2_o),
        .qspi_dq2_i(qspi_if_dq2_i),
        .qspi_dq3_en(qspi_if_dq3_en),
        .qspi_dq3_o(qspi_if_dq3_o),
        .qspi_dq3_i(qspi_if_dq3_i),

        .clk(clk),
        .rst_n(rst_n)
    );

    //for write/dummy/read register , we assert response at once;
    assign  qspi_if_rsp_vld     =   qspi_read_tr_r ? qspi_rsp_vld : 1'b1;

    assign  qspi_rsp_rdy        =   qspi_if_rsp_rdy;

    assign  qspi_if_rsp_dat     =   {8{qspi_config0_sel}}   & qspi_config0_r
                                   |{8{qspi_config1_sel}}   & {qspi_config1_r[7:3], qspi_busy, 2'b00}   
                                   |{8{qspi_data_sel}}      & qspi_rsp_dat;



    assign  qspi_if_csn         =   qspi_config1_r[3];

endmodule
