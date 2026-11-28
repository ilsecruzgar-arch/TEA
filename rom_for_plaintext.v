/////////////////////////////////////////////////////////////////////////////////////////////
// Company: ITESO  
// Engineer: Erendira Gamboa 
// Module Description: this module describes the ROM, which is a non-volatile memory that can only be read from.
// Date: 03/11/2026
//////////////////////////////////////////////////////////////////////////////////////////////

module rom_for_plaintext #(
    parameter N = 16,
    parameter DATA_WIDTH = 2*N,
    parameter ADDR_WIDTH = 4)
    (
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr_plaintext,
    output reg [DATA_WIDTH-1:0] plaintext_selected
);

    // ROM memory array
    reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];

    // Initialize ROM with some values (for example purposes)
    initial begin
        $readmemh("plaintext.txt", rom);
    end
    // Read data from ROM on clock edge
    always @(posedge clk) begin
        plaintext_selected <= rom[addr_plaintext];
    end

endmodule