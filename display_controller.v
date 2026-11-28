
// Company: ITESO
// Engineers: Erendira Gamboa, Ilse Cruz
//
// Module Description:
// Selects data according to the FSM state and displays
// hexadecimal pages on the DE10-Lite seven-segment displays.

module display_controller #(
    parameter N = 16,
    parameter STATE_WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire [STATE_WIDTH-1:0] state,
    input wire [2:0] display_page,
    // ROM preview data
    input wire [2*N-1:0] plaintext,
    input wire [4*N-1:0] key,
    // Registered data
    input wire [2*N-1:0] plaintext_reg,
    input wire [4*N-1:0] key_reg,
    input wire [2*N-1:0] ciphertext_reg,
    input wire [2*N-1:0] decrypted_reg,
    // System status
    input wire data_ready,
    input wire system_busy,
    input wire encrypt_busy,
    input wire decrypt_busy,
    input wire success_flag,
    input wire error_flag,
    // FPGA outputs
    output wire [9:0] LEDR,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    // FSM state definitions
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


    // Internal signals
    reg [4*N-1:0] selected_data;
    reg [23:0] display_data;
    wire [1:0] page_index;
    assign page_index = display_page[1:0];


    // Data selection
    always @(*) begin
        selected_data = {4*N{1'b0}};

        case (state)
            IDLE, LOAD_DATA: begin
                if (display_page[2])
                    selected_data = key;
                else
                    selected_data = plaintext;
            end

            READY_ENCRYPT,
            START_ENCRYPT,
            WAIT_ENCRYPT,
            STORE_ENCRYPT: begin
                if (display_page[2])
                    selected_data = key_reg;
                else
                    selected_data = plaintext_reg;
            end

            READY_DECRYPT,
            START_DECRYPT,
            WAIT_DECRYPT,
            STORE_DECRYPT: begin
                selected_data = ciphertext_reg;
            end

            READY_COMPARE,
            COMPARE: begin
                selected_data = decrypted_reg;
            end

            FINISH: begin
                selected_data = decrypted_reg;
            end

            default: begin
                selected_data = {4*N{1'b0}};
            end
        endcase
    end

    // Display page selection
    always @(posedge clk or posedge rst) begin
        if (rst) display_data <= 24'b0;
        else if (((state == IDLE) || (state == LOAD_DATA)) && !data_ready) display_data <= 24'b0;
        else display_data <= selected_data >> (24 * page_index);
    end

    // Hexadecimal to seven-segment decoder
    // Active-low outputs: {g,f,e,d,c,b,a}
    function [6:0] hex_to_7seg;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_7seg = 7'b1000000;
                4'h1: hex_to_7seg = 7'b1111001;
                4'h2: hex_to_7seg = 7'b0100100;
                4'h3: hex_to_7seg = 7'b0110000;

                4'h4: hex_to_7seg = 7'b0011001;
                4'h5: hex_to_7seg = 7'b0010010;
                4'h6: hex_to_7seg = 7'b0000010;
                4'h7: hex_to_7seg = 7'b1111000;

                4'h8: hex_to_7seg = 7'b0000000;
                4'h9: hex_to_7seg = 7'b0010000;
                4'hA: hex_to_7seg = 7'b0001000;
                4'hB: hex_to_7seg = 7'b0000011;

                4'hC: hex_to_7seg = 7'b1000110;
                4'hD: hex_to_7seg = 7'b0100001;
                4'hE: hex_to_7seg = 7'b0000110;
                4'hF: hex_to_7seg = 7'b0001110;

                default:
                    hex_to_7seg = 7'b1111111;
            endcase
        end
    endfunction


    // Seven-segment displays
    assign HEX0 = hex_to_7seg(display_data[3:0]);
    assign HEX1 = hex_to_7seg(display_data[7:4]);
    assign HEX2 = hex_to_7seg(display_data[11:8]);
    assign HEX3 = hex_to_7seg(display_data[15:12]);
    assign HEX4 = hex_to_7seg(display_data[19:16]);
    assign HEX5 = hex_to_7seg(display_data[23:20]);


    // LED indicators
    assign LEDR[3:0] = state[3:0];
    assign LEDR[4] = data_ready;
    assign LEDR[5] = system_busy;
    assign LEDR[6] = encrypt_busy;
    assign LEDR[7] = decrypt_busy;
    assign LEDR[8] = success_flag;
    assign LEDR[9] = error_flag;

endmodule
