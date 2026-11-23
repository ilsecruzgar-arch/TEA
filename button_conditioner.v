///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Eréndira Gamboa
// Module Description: This module conditions a push-button
// input signal by filtering and stabilizing the button state, it generates a clean output 
// suitable for reliable digital system operation.
// Date: 11/21/2026
///////////////////////////////////////////////////////////////
module button_conditioner (
    input wire clk,
    input wire rst_n,
    input wire button_in,
    output reg button_out
);

debouncer debouncer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .button_in(button_in),
    .button_out(button_out)
);


endmodule

