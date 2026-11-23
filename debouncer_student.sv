//////////////////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Erendira Gamboa 
// Module Description: this module describes the Debouncer, which filters the raw
// push button input to eliminate mechanical bouncing. It generates a clean and
// stable pulse used by the Counter to advance operations.
// Date: 09/29/2026
//////////////////////////////////////////////////////////////////////////////////////////////
module debouncer #(parameter int unsigned PRESS_TIMEOUT=100, parameter int unsigned RELEASE_TIMEOUT=500)
(input logic clk, 
input logic rst_n, 
input logic raw_btn, 
output logic debounced_btn );
typedef enum logic [2:0] { 
    OOO00OOO0OO0 = 3'b000, 
    OO0OOO0OO0O0 = 3'b001, 
    O000O00O000O = 3'b010, 
    OOO0000000OO = 3'b011, 
    OOO00O00O000 = 3'b100 } 
    O0O0OO0OOO0O; 
    O0O0OO0OOO0O OOO0O0OOOO00, 
    OOO0OOO0O00O; 
    localparam int OOOO0O00OO0O = (PRESS_TIMEOUT > RELEASE_TIMEOUT) ? PRESS_TIMEOUT : RELEASE_TIMEOUT; 
    logic [$clog2(OOOO0O00OO0O+1)-1:0] O00000O0O000; 
    logic OO0O0OO0OOOO; 
    logic OO0O0O00OO0O, OOO0000O0000; 
    assign OO0O0O00OO0O = O00000O0O000 >= PRESS_TIMEOUT; 
    assign OOO0000O0000 = O00000O0O000 >= RELEASE_TIMEOUT; 
    always_ff @(posedge clk, negedge rst_n)
    begin if(!rst_n)begin OOO0O0OOOO00 <= OOO00OOO0OO0; 
    end 
    else begin OOO0O0OOOO00 <= OOO0OOO0O00O; 
    end 
    end always_ff @(posedge clk, negedge rst_n)
    begin if(!rst_n)begin O00000O0O000 <= '0; 
    end else if(OO0O0OO0OOOO)begin O00000O0O000 <='0; 
    end else begin O00000O0O000 <= O00000O0O000+1; 
    end 
    end 
    always_comb begin OOO0OOO0O00O = OOO0O0OOOO00; 
    unique case (OOO0O0OOOO00) OOO00OOO0OO0: 
    begin if(raw_btn)begin OOO0OOO0O00O = OO0OOO0OO0O0; 
    end 
    end 
    OO0OOO0OO0O0: begin if(!raw_btn)begin OOO0OOO0O00O = OOO00OOO0OO0; 
    end else if(raw_btn && OO0O0O00OO0O)begin OOO0OOO0O00O = O000O00O000O; 
    end else begin OOO0OOO0O00O = OOO0O0OOOO00; 
    end 
    end 
    O000O00O000O: begin OOO0OOO0O00O = OOO0000000OO; 
    end 
    OOO0000000OO: begin if(!raw_btn)begin OOO0OOO0O00O = OOO00O00O000; 
    end else begin OOO0OOO0O00O = OOO0000000OO; 
    end 
    end 
    OOO00O00O000: begin if(!raw_btn && OOO0000O0000)begin OOO0OOO0O00O = OOO00OOO0OO0; 
    end else begin OOO0OOO0O00O = OOO0O0OOOO00; 
    end 
    end default: begin OOO0OOO0O00O = OOO00OOO0OO0; 
    end 
    endcase 
    end 
    always_comb begin debounced_btn = 1'b0; 
    OO0O0OO0OOOO = 1'b1; 
    unique case (OOO0O0OOOO00) OOO00OOO0OO0: begin debounced_btn = 1'b0; 
    OO0O0OO0OOOO = 1'b1; 
    end 
    OO0OOO0OO0O0: begin debounced_btn = 1'b0; 
    OO0O0OO0OOOO = 1'b0; 
    end 
    O000O00O000O: begin debounced_btn = 1'b1; 
    OO0O0OO0OOOO = 1'b1; 
    end 
    OOO0000000OO: begin debounced_btn = 1'b0; 
    OO0O0OO0OOOO = 1'b1;
    end 
    OOO00O00O000: begin debounced_btn = 1'b0; 
    OO0O0OO0OOOO = 1'b0; 
    end 
    default: begin debounced_btn = 1'b0; 
    OO0O0OO0OOOO = 1'b1; 
    end 
    endcase 
    end 
    endmodule