
///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineers: Erendira Gamboa, Ilse Cruz
//
// Module Description:
// Performs a bit-by-bit comparison between the original
// plaintext and the decrypted text.
///////////////////////////////////////////////////////////////

module comparator #(
  parameter N = 16
)(
  input wire clk,
  input wire rst,
  input wire compare_enable,
  input wire clear_result,
  input wire [2*N-1:0] plaintext_reg,
  input wire [2*N-1:0] decrypted_reg,
  output reg [2*N-1:0] compare_result,
  output reg success_flag,
  output reg error_flag,
  output reg compare_done
);

  wire [2*N-1:0] xor_result;
  assign xor_result = plaintext_reg ^ decrypted_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      compare_result <= {2*N{1'b0}};
      success_flag <= 1'b0;
      error_flag <= 1'b0;
      compare_done <= 1'b0;
    end
    else if (clear_result) begin
      compare_result <= {2*N{1'b0}};
      success_flag <= 1'b0;
      error_flag <= 1'b0;
      compare_done <= 1'b0;
    end
    else if (compare_enable) begin
      compare_result <= xor_result;
      success_flag <= ~(|xor_result);
      error_flag <= |xor_result;
      compare_done <= 1'b1;
    end
    else begin
      compare_done <= 1'b0;
    end
  end
endmodule
