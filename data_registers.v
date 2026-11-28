///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Erendira Gamboa, Ilse Cruz
// Module Description: Stores ciphertext and decrypted data
// into internal registers.
///////////////////////////////////////////////////////////////
module data_registers #(
    parameter N = 16,
    parameter DATA_WIDTH = 8)
    (
    input wire clk,
    input wire rst_n,
    input wire [2*N-1:0] ciphertext_in,
    input wire [2*N-1:0] decrypted_in,
    //input wire load_plaintext,
    //input wire load_key,
    input wire load_ciphertext,
    input wire load_decrypted,
    //input wire plaintext_in[2*N-1:0],     //Already stored in input_manager.v
    //input wire key_in[4*N-1:0],           //Already stored in input_manager.v

    output reg [2*N-1:0] ciphertext_out,
    output reg [2*N-1:0] decrypted_out
    //output reg plaintext_out[2*N-1:0],     //Already stored in input_manager.v
    //output reg key_out[4*N-1:0]     //Already stored in input_manager.v
);

always @(posedge clk) begin
    if (!rst_n) begin
        ciphertext_out <= {2*N{1'b0}};
        decrypted_out <= {2*N{1'b0}};
    end
    else begin
        if (load_ciphertext) begin
            ciphertext_out <= ciphertext_in;
        end
        if (load_decrypted) begin
            decrypted_out <= decrypted_in;
        end
    end
end

endmodule