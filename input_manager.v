///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineers: Erendira Gamboa, Ilse Cruz
//
// Module Description:
// Selects plaintext and key from synchronous ROM memories.
// Stores both blocks when load_data is asserted.
///////////////////////////////////////////////////////////////

module input_manager #(
  parameter N = 16,
  parameter PLAINTEXT_ADDR_WIDTH = 3,
  parameter KEY_ADDR_WIDTH = 3
)(
  input wire clk,
  input wire rst,
  input wire [PLAINTEXT_ADDR_WIDTH-1:0] plaintext_addr,
  input wire [KEY_ADDR_WIDTH-1:0] key_addr,
  input wire load_data,
  output reg [2*N-1:0] plaintext_reg,
  output reg [4*N-1:0] key_reg,
  output wire data_ready,
  output wire [2*N-1:0] plaintext,
  output wire [4*N-1:0] key
);

  // Internal signals
  wire [2*N-1:0] plaintext_selected;
  wire [4*N-1:0] key_selected;
  reg [PLAINTEXT_ADDR_WIDTH-1:0] plaintext_addr_q;
  reg [KEY_ADDR_WIDTH-1:0] key_addr_q;
  reg rom_valid;


  // Plaintext ROM
  rom_for_plaintext #(
    .N(N),
    .DATA_WIDTH(2*N),
    .ADDR_WIDTH(PLAINTEXT_ADDR_WIDTH)
  ) u_rom_for_plaintext (
    .clk(clk),
    .addr_plaintext(plaintext_addr),
    .plaintext_selected(plaintext_selected)
  );


  // Key ROM
  rom_for_key #(
    .N(N),
    .DATA_WIDTH(4*N),
    .ADDR_WIDTH(KEY_ADDR_WIDTH)
  ) u_rom_for_key (
    .clk(clk),
    .addr_key(key_addr),
    .key_selected(key_selected)
  );


  // ROM address tracking
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      plaintext_addr_q <= 0;
      key_addr_q <= 0;
      rom_valid <= 1'b0;
    end
    else begin
      plaintext_addr_q <= plaintext_addr;
      key_addr_q <= key_addr;
      rom_valid <= 1'b1;
    end
  end


  // Data ready
  assign data_ready = rom_valid && (plaintext_addr_q == plaintext_addr) && (key_addr_q == key_addr);


  // Plaintext and key registers
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      plaintext_reg <= {2*N{1'b0}};
      key_reg <= {4*N{1'b0}};
    end
    else if (load_data && data_ready) begin
      plaintext_reg <= plaintext_selected;
      key_reg <= key_selected;
    end
  end

  assign plaintext = plaintext_selected;
  assign key = key_selected;

endmodule
