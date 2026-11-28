/////////////////////////////////////////////////////////////////////////////////////////////
// Company: ITESO  
// Engineer: Erendira Gamboa 
// Module Description: this module describes the ROM, which is a non-volatile memory that can only be read from.
// Date: 03/11/2026
//////////////////////////////////////////////////////////////////////////////////////////////

module rom_for_key #(
    parameter N = 16,
    parameter DATA_WIDTH = 4*N,
    parameter ADDR_WIDTH = 4)
    (
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr_key,
    output reg [DATA_WIDTH-1:0] key_selected
);

    // ROM memory array
    reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];

    // Initialize ROM with some values (for example purposes)
    initial begin
        $readmemh("keys_4N.txt", rom);
    end
    // Read data from ROM on clock edge
    always @(posedge clk) begin
        key_selected <= rom[addr_key];
    end

endmodule