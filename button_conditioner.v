///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Eréndira Gamboa
// Module Description: This module conditions a push-button
// input signal by filtering and stabilizing the button state, it generates a clean output 
// suitable for reliable digital system operation.
// Date: 11/21/2026
///////////////////////////////////////////////////////////////

module button_conditioner #(
  parameter PRESS_TIMEOUT   = 500000,
  parameter RELEASE_TIMEOUT = 500000
)(
  input wire clk,
  input wire rst,
  input wire button_in,
  output wire button_pulse
);

  // Two-stage synchronizer
  reg button_sync_1;
  reg button_sync_2;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      button_sync_1 <= 1'b0;
      button_sync_2 <= 1'b0;
    end
    else begin
      button_sync_1 <= button_in;
      button_sync_2 <= button_sync_1;
    end
  end

  // Debouncer instance
  debouncer #(
    .PRESS_TIMEOUT(PRESS_TIMEOUT),
    .RELEASE_TIMEOUT(RELEASE_TIMEOUT)
  ) u_debouncer (
    .clk(clk),
    .rst_n(~rst),
    .raw_btn(button_sync_2),
    .debounced_btn(button_pulse)
  );

endmodule
