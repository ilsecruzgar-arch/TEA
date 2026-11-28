

`timescale 1ns / 1ps

module tb_input_manager;

parameter N = 16;
parameter ADDR_WIDTH = 4;

reg clk;
reg rst_n;
reg [ADDR_WIDTH-1:0] addr_plaintext;
reg [ADDR_WIDTH-1:0] addr_key;
reg data_or_key;
reg add_byte;
reg load_enable;

wire [2*N-1:0] plaintext_selected;
wire [4*N-1:0] key_selected;
wire [2*N-1:0] plaintext;
wire [4*N-1:0] key;
wire data_ready;

rom_for_plaintext #(
    .N(N),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_rom_plaintext (
    .clk(clk),
    .addr_plaintext(addr_plaintext),
    .plaintext_selected(plaintext_selected)
);

rom_for_key #(
    .N(N),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_rom_key (
    .clk(clk),
    .addr_key(addr_key),
    .key_selected(key_selected)
);

input_manager #(
    .N(N)
) u_input_manager (
    .clk(clk),
    .rst_n(rst_n),
    .data_or_key(data_or_key),
    .add_byte(add_byte),
    .load_enable(load_enable),
    .plaintext_in(plaintext_selected),
    .key_in(key_selected),
    .plaintext(plaintext),
    .key(key),
    .data_ready(data_ready)
);

always #10 clk = ~clk;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    addr_plaintext = 4'd0;
    addr_key = 4'd0;
    data_or_key = 1'b0;
    add_byte = 1'b0;
    load_enable = 1'b0;

    #40;
    rst_n = 1'b1;
    load_enable = 1'b1;

    addr_plaintext = 4'h2;
    addr_key = 4'h3;

    #40;

    data_or_key = 1'b0;
    add_byte = 1'b1;
    #20;
    add_byte = 1'b0;

    #20;

    data_or_key = 1'b1;
    add_byte = 1'b1;
    #20;
    add_byte = 1'b0;

    #20;

    $display("PRUEBA 1");
    $display("Plaintext: %h", plaintext);
    $display("Key: %h", key);
    $display("Data Ready: %b", data_ready);

    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;

    addr_plaintext = 4'h3;
    addr_key = 4'h6;

    #40;

    data_or_key = 1'b0;
    add_byte = 1'b1;
    #20;
    add_byte = 1'b0;

    #20;

    data_or_key = 1'b1;
    add_byte = 1'b1;
    #20;
    add_byte = 1'b0;

    #20;

    $display("PRUEBA 2");
    $display("Plaintext: %h", plaintext);
    $display("Key: %h", key);
    $display("Data Ready: %b", data_ready);

    $stop;
end

endmodule
