module spi(
    input       i_spi_vld,
    output      i_spi_rdy,
    input       i_spi_continue,//spi should continue after this byte transfer complete.
    input [7:0] i_spi_dat,
    input [1:0] i_spi_type,//2'b00: standard spi.2'b01: Dual SPI . 2'b10 : Quad SPI

    //SPI PARAM
    input [3:0] spi_div_param,
    input       spi_mod_0,

    output      o_spi_sck,
    output      o_spi_csn,
    output      o_spi_dq0_en,//MOSI
    // input       o_spi_dq0_i,
    output      o_spi_dq0_o,
    output      o_spi_dq1_en,//MISO
    // input       o_spi_dq1_i,
    output      o_spi_dq1_o,
    output      o_spi_dq2_en,
    // input       o_spi_dq2_i,
    output      o_spi_dq2_o,
    output      o_spi_dq3_en,
    // input       o_spi_dq3_i,
    output      o_spi_dq3_o,



    input       clk,
    input       rst_n
);
    //hand shake
    wire        i_spi_hsked =   i_spi_vld   &   i_spi_rdy;

    wire        spi_buf_vld_r;
    wire        spi_buf_vld_nxt;
    wire        spi_buf_vld_set;
    wire        spi_buf_vld_clr;
    wire        spi_buf_vld_ena;

    assign      spi_buf_vld_set     =   i_spi_hsked;
    assign      spi_buf_vld_nxt     =   spi_buf_vld_set | ~spi_buf_vld_clr;
    assign      spi_buf_vld_ena     =   spi_buf_vld_set | spi_buf_vld_clr;
    dfflr #(1)  spi_buf_vld_dfflr(spi_buf_vld_ena, spi_buf_vld_nxt, spi_buf_vld_r, clk, rst_n);

    assign      i_spi_rdy           =   ~spi_buf_vld_r  | spi_buf_vld_clr;

    wire        spi_buf_continue_r;
    wire        spi_buf_continue_nxt;

    wire [7:0]  spi_buf_dat_r;
    wire [7:0]  spi_buf_dat_nxt;

    wire [1:0]  spi_buf_type_r;
    wire [1:0]  spi_buf_type_nxt;

    assign      spi_buf_continue_nxt=   i_spi_continue;
    assign      spi_buf_dat_nxt     =   i_spi_dat;
    assign      spi_buf_type_nxt    =   i_spi_type;

    dfflr #(1)  spi_buf_continue_dfflr(spi_buf_vld_ena, spi_buf_continue_nxt, spi_buf_continue_r, clk, rst_n);
    dfflr #(8)  spi_buf_dat_dfflr(spi_buf_vld_ena, spi_buf_dat_nxt, spi_buf_dat_r, clk, rst_n);
    dfflr #(2)  spi_buf_type_dfflr(spi_buf_vld_ena, spi_buf_type_nxt, spi_buf_type_r, clk, rst_n);


    // wire [7:0]  rptr_vec_r;
    // wire [7:0]  rptr_vec_nxt;
    // wire        rptr_vec_ena;
    
    // assign      rptr_vec_nxt        =   rptr_vec_r[0] ? 8'b10000000 : {rptr_vec_r[0], rptr_vec_r[7:1]};
    
    // dfflr #(7)  rptr_vec_6_0_dfflr(rptr_vec_ena, rptr_vec_nxt[6:0], rptr_vec_r[6:0], clk, rst_n);
    // dfflrs #(1) rptr_vec_7_dfflrs(rptr_vec_ena, rptr_vec_nxt[7], rptr_vec_r[7], clk, rst_n);

    // wire        spi_tx_bit          =   |(spi_buf_dat_r & rptr_vec_r);

    // -------------------------------------------------------
    // -- SPI sck counter
    // -------------------------------------------------------\
    reg [10:0]  sck_div_count;
    always@(*) begin
        case (spi_div_param)
            4'b0000 :       sck_div_count   = 11'h000;//div 2
            4'b0001 :       sck_div_count   = 11'h001;//div 4
            4'b0010 :       sck_div_count   = 11'h007;//div 16
            4'b0011 :       sck_div_count   = 11'h00f;//div 32
            4'b0100 :       sck_div_count   = 11'h003;
            4'b0101 :       sck_div_count   = 11'h01f;
            4'b0110 :       sck_div_count   = 11'h03f;
            4'b0111 :       sck_div_count   = 11'h07f;
            4'b1000 :       sck_div_count   = 11'h0ff;
            4'b1001 :       sck_div_count   = 11'h1ff;
            4'b1010 :       sck_div_count   = 11'h3ff;
            4'b1011 :       sck_div_count   = 11'h7ff;
            default :       sck_div_count   = 11'h000;
        endcase
    end

    wire [10:0] sck_div_count_r;
    wire [10:0] sck_div_count_nxt;
    wire        sck_div_count_ena;

    wire        div_counting_complete       =   (sck_div_count_r == sck_div_count);

    assign      sck_div_count_nxt           =    (sck_div_count_r + 1);

    dfflr #(11) sck_div_count_dfflr(sck_div_count_ena, sck_div_count_nxt, sck_div_count_r, clk, rst_n);
    
    

    //SPI state
    localparam  SPI_IDLE    = 2'b00;
    localparam  SPI_TRANSFER= 2'b01;
    localparam  SPI_PAUSE   = 2'b10;

    wire [1:0]  spi_state_r;
    wire [1:0]  spi_state_nxt;
    wire        spi_state_ena;

    dfflr #(2)  spi_state_dfflr(spi_state_ena, spi_state_nxt, spi_state_r, clk, rst_n);

    wire        spi_state_is_idle       =   (spi_state_r == SPI_IDLE);
    wire        spi_state_is_transfer   =   (spi_state_r == SPI_TRANSFER);
    wire        spi_state_is_pause      =   (spi_state_r == SPI_PAUSE);

    



    //bit transfer state

    assign      sck_div_count_ena       =   spi_state_is_transfer;

    localparam  SCK_LOW = 1'b0;
    localparam  SCK_HIGH= 1'b1;

    wire        bit_tx_state_r;
    wire        bit_tx_state_nxt;
    wire        bit_tx_state_ena;
    
    wire        bit_tx_state_is_sck_low =   (bit_tx_state_r == SCK_LOW);
    wire        bit_tx_state_is_sck_high=   (bit_tx_state_r == SCK_HIGH);

    assign      bit_tx_state_ena        =   ~spi_state_is_transfer | div_counting_complete;
    assign      bit_tx_state_nxt        =   spi_state_is_transfer && ((bit_tx_state_is_sck_low & SCK_HIGH) | (bit_tx_state_is_sck_high & SCK_LOW));

    dfflr #(1)  bit_tx_state_dfflr(bit_tx_state_ena, bit_tx_state_nxt, bit_tx_state_r, clk, rst_n);
    
    
    // -------------------------------------------------------
    // -- spi type
    // -------------------------------------------------------
    wire        standard_spi            =   (spi_buf_type_r == 2'b00);
    wire        dual_spi                =   (spi_buf_type_r == 2'b01);
    wire        quad_spi                =   (spi_buf_type_r == 2'b10);

    //bit transfer counting
    wire [2:0]  bit_tx_count_r;
    wire [2:0]  bit_tx_count_nxt;
    wire        bit_tx_count_ena;
    
    assign      bit_tx_count_nxt        =   {3{spi_state_is_transfer}} & (
                                                                            ({3{standard_spi}} & (bit_tx_count_r + 1))
                                                                        |   ({3{dual_spi}} & (bit_tx_count_r + 2))
                                                                        |   ({3{quad_spi}} & (bit_tx_count_r + 4))
                                                                            );
    assign      bit_tx_count_ena        =   ~spi_state_is_transfer | (bit_tx_state_is_sck_high & bit_tx_state_ena);

    dfflr #(3)  bit_tx_count_dfflr(bit_tx_count_ena, bit_tx_count_nxt, bit_tx_count_r, clk, rst_n);

    wire        spi_byte_transfer_finish=  spi_state_is_transfer & ((standard_spi & (bit_tx_count_r == 3'b111))
                                        |   (dual_spi & (bit_tx_count_r == 3'b110))
                                        |   (quad_spi & (bit_tx_count_r == 3'b100))) & bit_tx_state_ena & bit_tx_state_is_sck_high;




    wire        spi_state_idle_ena      =   spi_state_is_idle & i_spi_hsked;
    wire        spi_state_pause_ena     =   spi_state_is_pause& i_spi_hsked;
    wire        spi_state_transfer_ena  =   spi_state_is_transfer & spi_byte_transfer_finish;

    wire [1:0]  spi_state_idle_nxt      =   SPI_IDLE;
    wire [1:0]  spi_state_pause_nxt     =   SPI_TRANSFER;
    wire [1:0]  spi_state_transfer_nxt  =   i_spi_hsked ? SPI_TRANSFER : 
                                                          spi_buf_continue_r ? SPI_PAUSE :  SPI_IDLE;

    assign      spi_state_ena           =   spi_state_idle_ena | spi_state_pause_ena | spi_state_transfer_ena;
    assign      spi_state_nxt           =   {2{spi_state_is_idle}} & spi_state_idle_nxt
                                        |   {2{spi_state_is_pause}}& spi_state_pause_nxt
                                        |   {2{spi_state_is_transfer}}  & spi_state_transfer_nxt;
                                        

    assign      spi_buf_vld_clr         =   spi_byte_transfer_finish;
    
//SPI singal
    wire [7:0]  spi_bit_idx             =   8'b10000000 >> bit_tx_count_r;
    wire        spi_tx_bit              =   |(spi_buf_dat_r & spi_bit_idx);
           
    assign      o_spi_sck               =   spi_state_is_idle & ~spi_mod_0
                                        |   spi_state_is_pause
                                        |   spi_state_is_transfer & (bit_tx_state_is_sck_high);

    assign      o_spi_csn               =   ~(
                                            spi_state_is_pause | spi_state_is_transfer
                                                );                                    

    assign      o_spi_dq0_en            =   spi_state_is_pause | spi_state_is_transfer;

    assign      o_spi_dq0_o             =   ~spi_state_is_idle & (standard_spi & spi_tx_bit
                                                                | dual_spi & |(spi_buf_dat_r & (spi_bit_idx >> 1))
                                                                | quad_spi & |(spi_buf_dat_r & (spi_bit_idx >> 3))
                                                                );


    assign      o_spi_dq1_en            =   (dual_spi | quad_spi) & ~spi_state_is_idle;
    
    assign      o_spi_dq1_o             =   ~spi_state_is_idle  & (
                                                                    dual_spi & |(spi_buf_dat_r & spi_bit_idx)
                                                                |   quad_spi & |(spi_buf_dat_r & (spi_bit_idx >> 2))
                                                                );

    assign      o_spi_dq2_en            =   quad_spi & ~spi_state_is_idle;

    assign      o_spi_dq2_o             =   ~spi_state_is_idle & |(spi_buf_dat_r & (spi_bit_idx >> 1));

    assign      o_spi_dq3_en            =   quad_spi & ~spi_state_is_idle;

    assign      o_spi_dq3_o             =   ~spi_state_is_idle & |(spi_buf_dat_r & spi_bit_idx);

    
    

    

    
    



endmodule
