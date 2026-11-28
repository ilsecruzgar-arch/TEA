///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Erendira Gamboa, Ilse Cruz
// Module Description: Compares the plaintext and decrypted
// data and reports the comparison result.
///////////////////////////////////////////////////////////////
module comparator #(
    parameter N = 16,
    parameter DATA_WIDTH = 8)
    (
    input wire clk,
    input wire rst_n,
    input wire [2*N-1:0] plaintext,
    input wire [2*N-1:0] decrypted_text,
    input wire compare_enable,

    output reg equal_flag,
    output reg error_flag,
    output reg compare_done
);

always @(posedge clk) begin
    if (!rst_n) begin
        equal_flag <= 1'b0;
        error_flag <= 1'b0;
        compare_done <= 1'b0;
    end else if (compare_enable) begin
        equal_flag <= (plaintext ^ decrypted_text)? 1'b0 : 1'b1; // XOR operation to compare plaintext and decrypted_text
        error_flag <= (plaintext ^ decrypted_text)? 1'b1 : 1'b0; // Set error_flag if compare_result is not zero
        compare_done <= 1'b1;
    end else begin
        compare_done <= 1'b0; // Reset compare_done when not enabled
    end
end
endmodule