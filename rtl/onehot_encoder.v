module onehot_encoder
#(parameter ONEHOT_WIDTH = 4)(
    input   [ONEHOT_WIDTH-1:0] in,
    output reg [$clog2(ONEHOT_WIDTH)-1:0] out
);
    always@(*) begin
        out = 0;
        for(int i=0; i < ONEHOT_WIDTH; i = i+1) begin
            if(in[i])
                out = i;
        end
    end
endmodule
