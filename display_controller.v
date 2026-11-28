module display_controller#(
    parameter N = 16)(
    input wire clk,
    input wire rst_n,
    input display_select, 
    input [2*N-1:0] plaintext, 
    input [4*N-1:0] key, 
    input [3:0] state, 
    output reg [4*N-1:0] data_out
);

always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            data_out <= {4*N{1'b0}};
        end else  if (display_select) begin
            data_out <= plaintext;
        end else begin
            data_out <= key;
        end
    end

endmodule