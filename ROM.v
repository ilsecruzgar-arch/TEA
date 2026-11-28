module ReadOnlyMemory#(
	parameter PLAINTEXT_WIDTH = 32, 
	parameter KEY_WIDTH = 64,
	parameter PLAINTEXT_ADDR_WIDTH = 5, 
	parameter KEY_ADDR_WIDTH = 4
	)(
// inputs
input clk,
input [PLAINTEXT_ADDR_WIDTH-1:0]addr_plaintext, 
input [KEY_ADDR_WIDTH-1:0]addr_key,
// outputs
output reg [PLAINTEXT_WIDTH-1:0]q_plaintext,
output reg [KEY_WIDTH-1:0]q_key);

// ROM plaintext
reg [PLAINTEXT_WIDTH-1:0] rom_plaintext [0:(2**PLAINTEXT_ADDR_WIDTH)-1];
// ROM key
reg [KEY_WIDTH-1:0] rom_key [0:(2**KEY_ADDR_WIDTH)-1];

// Lectura sincrona
// $readmemh -> archivo de entrada en formato .txt o .hex
initial
begin
	$readmemh("ROM_plaintext.txt", rom_plaintext);
	$readmemh("ROM_key.txt",       rom_key);
end
always @(posedge clk)
begin
 q_plaintext <= rom_plaintext[addr_plaintext];
 q_key <= rom_key[addr_key];
end

endmodule
