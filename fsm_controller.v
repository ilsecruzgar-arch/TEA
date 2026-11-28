
module fsm_controller #(
    parameter STATE_WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire next_state_button,
    input wire data_ready,
    input wire encrypt_busy,
    input wire encrypt_done,
    input wire decrypt_busy,
    input wire decrypt_done,

    output reg start_encrypt,
    output reg start_decrypt,
    output reg load_data,
    output reg load_ciphertext,
    output reg load_decrypted,
    output reg compare_enable,
    output reg system_busy,
    output reg [STATE_WIDTH-1:0] state
);

reg [STATE_WIDTH-1:0] next_state;

localparam [STATE_WIDTH-1:0]
    IDLE          = 4'd0,
    LOAD_DATA     = 4'd1,
    READY_ENCRYPT = 4'd2,
    START_ENCRYPT = 4'd3,
    WAIT_ENCRYPT  = 4'd4,
    STORE_ENCRYPT = 4'd5,
    READY_DECRYPT = 4'd6,
    START_DECRYPT = 4'd7,
    WAIT_DECRYPT  = 4'd8,
    STORE_DECRYPT = 4'd9,
    READY_COMPARE = 4'd10,
    COMPARE       = 4'd11,
    FINISH        = 4'd12;

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    next_state = state;

    case (state)

        IDLE: begin
            if (next_state_button)
                next_state = LOAD_DATA;
        end

        LOAD_DATA: begin
            if (data_ready)
                next_state = READY_ENCRYPT;
        end

        READY_ENCRYPT: begin
            if (!encrypt_busy && next_state_button)
                next_state = START_ENCRYPT;
        end

        START_ENCRYPT: begin
            next_state = WAIT_ENCRYPT;
        end

        WAIT_ENCRYPT: begin
            if (encrypt_done && !encrypt_busy)
                next_state = STORE_ENCRYPT;
        end

        STORE_ENCRYPT: begin
            next_state = READY_DECRYPT;
        end

        READY_DECRYPT: begin
            if (!decrypt_busy && next_state_button)
                next_state = START_DECRYPT;
        end

        START_DECRYPT: begin
            next_state = WAIT_DECRYPT;
        end

        WAIT_DECRYPT: begin
            if (decrypt_done && !decrypt_busy)
                next_state = STORE_DECRYPT;
        end

        STORE_DECRYPT: begin
            next_state = READY_COMPARE;
        end

        READY_COMPARE: begin
            if (next_state_button)
                next_state = COMPARE;
        end

        COMPARE: begin
            next_state = FINISH;
        end

        FINISH: begin
            next_state = FINISH;
        end

        default: begin
            next_state = IDLE;
        end

    endcase
end

always @(*) begin
    start_encrypt   = 1'b0;
    start_decrypt   = 1'b0;
    load_data       = 1'b0;
    load_ciphertext = 1'b0;
    load_decrypted  = 1'b0;
    compare_enable  = 1'b0;
    system_busy     = 1'b0;

    case (state)

        IDLE: begin
            system_busy = 1'b0;
        end

        LOAD_DATA: begin
            load_data   = 1'b1;
            system_busy = 1'b1;
        end

        READY_ENCRYPT: begin
            system_busy = 1'b1;
        end

        START_ENCRYPT: begin
            start_encrypt = 1'b1;
            system_busy   = 1'b1;
        end

        WAIT_ENCRYPT: begin
            system_busy = 1'b1;
        end

        STORE_ENCRYPT: begin
            load_ciphertext = 1'b1;
            system_busy     = 1'b1;
        end

        READY_DECRYPT: begin
            system_busy = 1'b1;
        end

        START_DECRYPT: begin
            start_decrypt = 1'b1;
            system_busy   = 1'b1;
        end

        WAIT_DECRYPT: begin
            system_busy = 1'b1;
        end

        STORE_DECRYPT: begin
            load_decrypted = 1'b1;
            system_busy    = 1'b1;
        end

        STORE_DECRYPT: begin
            load_decrypted = 1'b1;
            system_busy    = 1'b1;
        end

        COMPARE: begin
            compare_enable = 1'b1;
            system_busy    = 1'b1;
        end

        FINISH: begin
            system_busy = 1'b0;
        end

        default: begin
            system_busy = 1'b0;
        end

    endcase
end

endmodule
