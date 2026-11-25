///////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Erendira Gamboa, Ilse Cruz
//
// Module Description: Loads input bytes into the plaintext
// and key registers and generates a ready signal when the
// loading process is completed.
//
///////////////////////////////////////////////////////////////
module input_manager #(
    parameter N = 32,
    parameter DATA_WIDTH = 8)
    (
    input  wire clk,
    input  wire rst_n,
    input  wire [DATA_WIDTH-1:0] data,
    input  wire data_or_key,
    input  wire add_byte,
    input  wire load_enable,

    output reg [2*N-1:0] plaintext,
    output reg [4*N-1:0] key,
    output wire data_ready
);

localparam DATA_BYTES = (2*N)/DATA_WIDTH;
localparam KEY_BYTES  = (4*N)/DATA_WIDTH;
localparam DATA_COUNT_WIDTH = $clog2(DATA_BYTES+1);
localparam KEY_COUNT_WIDTH  = $clog2(KEY_BYTES+1);

reg [DATA_COUNT_WIDTH-1:0] data_count;
reg [KEY_COUNT_WIDTH-1:0] key_count;

assign data_ready = (data_count == DATA_BYTES) &&(key_count == KEY_BYTES);

always @(posedge clk) begin
    if(!rst_n) begin
        data_count <= 0;
        key_count <= 0;
        plaintext <= {2*N{1'b0}};
        key <= {4*N{1'b0}};
    end 
    else if (load_enable && add_byte) begin
        //low state is for data, high state is for key
        if (data_or_key == 1'b0) begin // Load data into plaintext
            if (data_count < DATA_BYTES) begin
                plaintext <= {plaintext[2*N-DATA_WIDTH-1:0], data};
                data_count <= data_count + 1'b1; 
                end 
        end
        else begin if (key_count < KEY_BYTES) begin // Load data into key
            key <= {key[4*N-DATA_WIDTH-1:0], data};
            key_count <= key_count + 1'b1;
            end
        end
    end
end

endmodule
