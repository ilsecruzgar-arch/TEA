///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Erendira Gamboa, Ilse Cruz
//
// Module Description: Loads input bytes into the plaintext
// and key registers and generates a ready signal when the
// loading process is completed.
//
///////////////////////////////////////////////////////////////

module input_manager #(
    parameter N = 16)(
    input  wire clk,
    input  wire rst_n,
    input  wire data_or_key,
    input  wire add_byte,
    input  wire load_enable,
    input  wire [2*N-1:0] plaintext_in,
    input  wire [4*N-1:0] key_in,

    output reg [2*N-1:0] plaintext,
    output reg [4*N-1:0] key,
    output wire data_ready
);

reg plaintext_loaded;
reg key_loaded;

assign data_ready = plaintext_loaded && key_loaded;

always @(posedge clk) begin
    if(!rst_n) begin
        plaintext <= {2*N{1'b0}};
        key <= {4*N{1'b0}};
        plaintext_loaded <= 1'b0;
        key_loaded <= 1'b0;
    end
    else if (load_enable && add_byte) begin
        if (data_or_key == 1'b0) begin
            plaintext <= plaintext_in;
            plaintext_loaded <= 1'b1;
        end
        else begin
            key <= key_in;
            key_loaded <= 1'b1;
        end
    end
end

endmodule
