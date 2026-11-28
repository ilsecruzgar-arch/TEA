
module tea_top #(
  parameter N = 16,
  parameter NUM_CYCLES = 32,
  parameter STATE_WIDTH = 4,
  parameter PLAINTEXT_ADDR_WIDTH = 3,
  parameter KEY_ADDR_WIDTH = 3
)(
  input MAX10_CLK1_50,
  input [9:0] SW,
  input [1:0] KEY,
  output [9:0] LEDR,
  output [6:0] HEX0,
  output [6:0] HEX1,
  output [6:0] HEX2,
  output [6:0] HEX3,
  output [6:0] HEX4,
  output [6:0] HEX5);

  // Clock and reset
  wire clk;
  wire rst;
  reg [1:0] reset_reg;
  assign clk = MAX10_CLK1_50;

  // Asynchronous assertion
  // Synchronous reset release
  always @(posedge clk or negedge KEY[1]) begin
    if (!KEY[1])
      reset_reg <= 2'b11;
    else
      reset_reg <= {reset_reg[0], 1'b0};
  end

  assign rst = reset_reg[1];

  // User interface
  wire next_state_button;
  wire error_enable;
  wire [PLAINTEXT_ADDR_WIDTH-1:0] plaintext_addr;
  wire [KEY_ADDR_WIDTH-1:0] key_addr;
  wire [2:0] display_page;
  reg [9:0] sw_sync_1;
  reg [9:0] sw_sync_2;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sw_sync_1 <= 10'b0;
      sw_sync_2 <= 10'b0;
    end
    else begin
      sw_sync_1 <= SW;
      sw_sync_2 <= sw_sync_1;
    end
  end
  

  assign error_enable   = sw_sync_2[0];
  assign plaintext_addr = sw_sync_2[3:1];
  assign key_addr       = sw_sync_2[6:4];
  assign display_page   = sw_sync_2[9:7];

  // Input Manager signals
  wire [2*N-1:0] plaintext;
  wire [4*N-1:0] key;
  wire data_ready;

  // Data Registers signals
  wire [2*N-1:0] plaintext_reg;
  wire [4*N-1:0] key_reg;
  wire [2*N-1:0] ciphertext_reg;
  wire [2*N-1:0] decrypted_reg;

  wire load_data;
  wire load_ciphertext;
  wire load_decrypted;

  // TEA Encrypt signals
  wire start_encrypt;
  wire encrypt_busy;
  wire encrypt_done;
  wire [2*N-1:0] ciphertext;

// TEA Decrypt signals
  wire start_decrypt;
  wire decrypt_busy;
  wire decrypt_done;
  wire [2*N-1:0] decrypted_text;

  // Comparator signals
  wire compare_enable;
  wire compare_done;
  wire [2*N-1:0] compare_result;
  wire success_flag;
  wire error_flag;

  // FSM Controller signals
  wire system_busy;
  wire [STATE_WIDTH-1:0] state;

  // Error injection
  reg error_enable_reg;
  wire [2*N-1:0] ciphertext_injected;

  // Capture error configuration when
  // decryption starts
  always @(posedge clk or posedge rst) begin
    if (rst)
      error_enable_reg <= 1'b0;
    else if (load_data)
      error_enable_reg <= 1'b0;
    else if (start_decrypt)
      error_enable_reg <= error_enable;
  end

  // Inject an arithmetic error
  assign ciphertext_injected = ciphertext_reg + {{(2*N-1){1'b0}}, error_enable};


  // 1. Button Conditioner
  button_conditioner u_button_next (
    .clk(clk),
    .rst(rst),
    .button_in(~KEY[0]),
    .button_pulse(next_state_button)
  );

  // 2. Input Manager
  // ROM Memory is instantiated internally
  input_manager #(
    .N(N),
    .PLAINTEXT_ADDR_WIDTH(PLAINTEXT_ADDR_WIDTH),
    .KEY_ADDR_WIDTH(KEY_ADDR_WIDTH)
  ) u_input_manager (
    .clk(clk),
    .rst(rst),
    .plaintext_addr(plaintext_addr),
    .key_addr(key_addr),
    .load_data(load_data),
    .plaintext(plaintext),
    .key(key),
    .plaintext_reg(plaintext_reg),
    .key_reg(key_reg),
    .data_ready(data_ready)
);

  // 3. Data Registers
  data_registers #(
    .N(N)
  ) u_data_registers (
    .clk(clk),
    .rst(rst),
    .load_ciphertext(load_ciphertext),
    .load_decrypted(load_decrypted),
    .ciphertext(ciphertext),
    .decrypted_text(decrypted_text),
    .ciphertext_reg(ciphertext_reg),
    .decrypted_reg(decrypted_reg)
  );

  // 4. FSM Controller
  fsm_controller #(
    .STATE_WIDTH(STATE_WIDTH)
  ) u_fsm_controller (
    .clk(clk),
    .rst(rst),
    .next_state_button(next_state_button),
    .data_ready(data_ready),
    .encrypt_busy(encrypt_busy),
    .encrypt_done(encrypt_done),
    .decrypt_busy(decrypt_busy),
    .decrypt_done(decrypt_done),
    .start_encrypt(start_encrypt),
    .start_decrypt(start_decrypt),
    .load_data(load_data),
    .load_ciphertext(load_ciphertext),
    .load_decrypted(load_decrypted),
    .compare_enable(compare_enable),
    .system_busy(system_busy),
    .state(state)
  );

  // 5. TEA Encrypt
  tea_encrypt #(
    .N(N),
    .NUM_CYCLES(NUM_CYCLES)
  ) u_tea_encrypt (
    .clk(clk),
    .rst(rst),
    .start_encrypt(start_encrypt),
    .plaintext(plaintext_reg),
    .key(key_reg),
    .ciphertext(ciphertext),
    .encrypt_busy(encrypt_busy),
    .encrypt_done(encrypt_done)
  );

  // 6. TEA Decrypt
  tea_decrypt #(
    .N(N),
    .NUM_CYCLES(NUM_CYCLES)
  ) u_tea_decrypt (
    .clk(clk),
    .rst(rst),
    .start_decrypt(start_decrypt),
    .ciphertext(ciphertext_injected),
    .key_reg(key_reg),
    .decrypted_text(decrypted_text),
    .decrypt_busy(decrypt_busy),
    .decrypt_done(decrypt_done)
  );

  // 7. Comparator
  comparator #(
    .N(N)
  ) u_comparator (
    .clk(clk),
    .rst(rst),
    .compare_enable(compare_enable),
    .clear_result(load_data),
    .plaintext_reg(plaintext_reg),
    .decrypted_reg(decrypted_reg),
    .compare_result(compare_result),
    .success_flag(success_flag),
    .error_flag(error_flag),
    .compare_done(compare_done)
  );

  // 8. Display Controller
  display_controller #(
    .N(N),
    .STATE_WIDTH(STATE_WIDTH)
  ) u_display_controller (
    .clk(clk),
    .rst(rst),
    .state(state),
    .display_page(display_page),
    .plaintext(plaintext),
    .key(key),
    .plaintext_reg(plaintext_reg),
    .key_reg(key_reg),
    .ciphertext_reg(ciphertext_reg),
    .decrypted_reg(decrypted_reg),
    .compare_result(compare_result),
    .data_ready(data_ready),
    .system_busy(system_busy),
    .encrypt_busy(encrypt_busy),
    .decrypt_busy(decrypt_busy),
    .success_flag(success_flag),
    .error_flag(error_flag),
    .LEDR(LEDR),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5)
  );

endmodule