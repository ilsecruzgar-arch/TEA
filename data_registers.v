///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineers: Erendira Gamboa, Ilse Cruz
//
// Module Description:
// Stores ciphertext and decrypted text into internal registers.
///////////////////////////////////////////////////////////////

module data_registers #(
  parameter N = 16
)(
  input wire clk,
  input wire rst,
  input wire load_ciphertext,
  input wire load_decrypted,
  input wire [2*N-1:0] ciphertext,
  input wire [2*N-1:0] decrypted_text,
  output reg [2*N-1:0] ciphertext_reg,
  output reg [2*N-1:0] decrypted_reg
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ciphertext_reg <= {2*N{1'b0}};
      decrypted_reg <= {2*N{1'b0}};
    end

    else begin
      if (load_ciphertext) ciphertext_reg <= ciphertext;
      if (load_decrypted) decrypted_reg <= decrypted_text;
    end
  end

endmodule
