
`timescale 1ns/1ps

module tea_tb;

  parameter N = 16;
  parameter NUM_CYCLES = 32;
  parameter CLK_PERIOD = 20;

  // Entradas
  reg clk;
  reg rst;
  reg start_encrypt;
  reg start_decrypt;
  reg [2*N-1:0] plaintext;
  reg [4*N-1:0] key_reg;

  // Salidas
  wire [2*N-1:0] ciphertext;
  wire [2*N-1:0] decrypted_text;
  wire encrypt_busy;
  wire encrypt_done;
  wire decrypt_busy;
  wire decrypt_done;

  // Variables de verificacion
  integer tests_passed;
  integer tests_failed;
  integer i;
  integer cycles;

  reg [2*N-1:0] expected_plaintext;

  // Instancia del cifrador
  tea_encrypt #(
    .N(N),
    .NUM_CYCLES(NUM_CYCLES)
  ) uut_encrypt (
    .clk(clk),
    .rst(rst),
    .start_encrypt(start_encrypt),
    .plaintext(plaintext),
    .key(key_reg),
    .ciphertext(ciphertext),
    .encrypt_busy(encrypt_busy),
    .encrypt_done(encrypt_done)
  );

  // Instancia del descifrador
  tea_decrypt #(
    .N(N),
    .NUM_CYCLES(NUM_CYCLES)
  ) uut_decrypt (
    .clk(clk),
    .rst(rst),
    .start_decrypt(start_decrypt),
    .ciphertext(ciphertext),
    .key_reg(key_reg),
    .decrypted_text(decrypted_text),
    .decrypt_busy(decrypt_busy),
    .decrypt_done(decrypt_done)
  );

  // Generacion del reloj
  initial clk = 1'b0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // Tarea de verificacion
  task run_test;
    input [2*N-1:0] test_plaintext;
    input [4*N-1:0] test_key;

    begin
      // Preparar entradas
      @(negedge clk);
      plaintext = test_plaintext;
      key_reg = test_key;
      expected_plaintext = test_plaintext;

      // Iniciar cifrado
      start_encrypt = 1'b1;

      @(negedge clk);
      start_encrypt = 1'b0;

      // Esperar finalizacion del cifrado
      cycles = 0;
      while (!encrypt_done && cycles < NUM_CYCLES+5) begin
        @(negedge clk);
        cycles = cycles + 1;
      end

      if (!encrypt_done) begin
        $display("ERROR: Timeout en cifrado");
        $finish;
      end

      if (encrypt_busy !== 1'b0) begin
        $display("ERROR: encrypt_busy no se desactivo");
        tests_failed = tests_failed + 1;
      end

      $display("Plaintext : %h", plaintext);
      $display("Key       : %h", key_reg);
      $display("Ciphertext: %h", ciphertext);

      // Iniciar descifrado
      start_decrypt = 1'b1;

      @(negedge clk);
      start_decrypt = 1'b0;

      // Esperar finalizacion del descifrado
      cycles = 0;
      while (!decrypt_done && cycles < NUM_CYCLES+5) begin
        @(negedge clk);
        cycles = cycles + 1;
      end

      if (!decrypt_done) begin
        $display("ERROR: Timeout en descifrado");
        $finish;
      end

      if (decrypt_busy !== 1'b0) begin
        $display("ERROR: decrypt_busy no se desactivo");
        tests_failed = tests_failed + 1;
      end

      $display("Decrypted : %h", decrypted_text);

      // Comparacion bit a bit
      if (decrypted_text === expected_plaintext) begin
        $display("PASS: Descifrado correcto");
        tests_passed = tests_passed + 1;
      end
      else begin
        $display("FAIL: Descifrado incorrecto");
        tests_failed = tests_failed + 1;
      end

      $display("--------------------------------");

      // Esperar a que ambos modulos regresen al estado IDLE
      repeat (2) @(negedge clk);
    end
  endtask

  // Secuencia principal
  initial begin

    rst = 1'b1;
    start_encrypt = 1'b0;
    start_decrypt = 1'b0;
    plaintext = {2*N{1'b0}};
    key_reg = {4*N{1'b0}};

    tests_passed = 0;
    tests_failed = 0;

    // Reset
    repeat (3) @(negedge clk);
    rst = 1'b0;

    $display("================================");
    $display("TEA ENCRYPT / DECRYPT TESTBENCH");
    $display("N = %0d, NUM_CYCLES = %0d", N, NUM_CYCLES);
    $display("================================");

    // T1: ceros
    run_test({2*N{1'b0}}, {4*N{1'b0}});

    // T2: unos
    run_test({2*N{1'b1}}, {4*N{1'b1}});

    // T3: patrones alternados
    run_test({(2*N/2){2'b10}}, {(4*N/2){2'b01}});

    // Test 4: Datos definidos
    run_test({{(2*N-32){1'b0}}, 32'h12345678}, {{(4*N-64){1'b0}}, 64'h0123456789ABCDEF});

    // Resumen
    $display("================================");
    $display("RESULTADOS");
    $display("Tests passed: %0d", tests_passed);
    $display("Tests failed: %0d", tests_failed);
    $display("================================");

    if (tests_failed == 0)
      $display("ALL TESTS PASSED");
    else
      $display("TESTBENCH FAILED");

    $stop;
  end

endmodule
