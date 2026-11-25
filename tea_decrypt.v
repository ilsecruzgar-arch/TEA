
module tea_decrypt #(
  parameter N = 16,
  parameter NUM_CYCLES = 32
)(
  input clk,
  input rst,
  input start_decrypt,
  input [2*N-1:0] ciphertext,
  input [4*N-1:0] key_reg,
  output reg [2*N-1:0] decrypted_text,
  output reg decrypt_busy,
  output reg decrypt_done
);

  // DELTA = floor((sqrt(5)-1) * 2^(N-1))
  // Valido para 1 <= N <= 64
  localparam [63:0] GOLDEN_RATIO = 64'h9E3779B97F4A7C15;
  localparam [N-1:0] DELTA = GOLDEN_RATIO >> (64-N);

  // Contador de rondas
  localparam COUNT_WIDTH = (NUM_CYCLES > 1) ? $clog2(NUM_CYCLES) : 1;
  reg [COUNT_WIDTH-1:0] round_count;

  // Estados de la FSM
  localparam [1:0] IDLE = 2'b00, RUN = 2'b01, FINISH = 2'b10;
  reg [1:0] state;

  // Registros internos
  reg [N-1:0] L_in, R_in;
  reg [N-1:0] k0, k1, k2, k3;
  reg [N-1:0] sum;

  // Resultados de la siguiente ronda
  wire [N-1:0] next_sum;
  wire [N-1:0] L_final;
  wire [N-1:0] R_final;

  // Descifrado: primero R, despues L
  assign R_final = R_in - (((L_in << 4) + k2) ^ (L_in + sum) ^ ((L_in >> 5) + k3));

  assign L_final = L_in - (((R_final << 4) + k0) ^ (R_final + sum) ^ ((R_final >> 5) + k1));

  assign next_sum = sum - DELTA;

  // Logica secuencial
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      L_in <= {N{1'b0}};
      R_in <= {N{1'b0}};
      k0 <= {N{1'b0}};
      k1 <= {N{1'b0}};
      k2 <= {N{1'b0}};
      k3 <= {N{1'b0}};
      sum <= {N{1'b0}};
      round_count <= {COUNT_WIDTH{1'b0}};
      decrypted_text <= {2*N{1'b0}};
      decrypt_busy <= 1'b0;
      decrypt_done <= 1'b0;
    end
    else begin
      case (state)

        IDLE: begin
          decrypt_busy <= 1'b0;
          decrypt_done <= 1'b0;

          if (start_decrypt) begin
            // Captura del ciphertext
            L_in <= ciphertext[2*N-1:N];
            R_in <= ciphertext[N-1:0];

            // Captura de la clave
            k0 <= key_reg[4*N-1:3*N];
            k1 <= key_reg[3*N-1:2*N];
            k2 <= key_reg[2*N-1:N];
            k3 <= key_reg[N-1:0];

            // Inicializacion de sum
            sum <= DELTA * NUM_CYCLES;
            round_count <= {COUNT_WIDTH{1'b0}};
            decrypt_busy <= 1'b1;
            state <= RUN;
          end
        end

        RUN: begin
          L_in <= L_final;
          R_in <= R_final;
          sum <= next_sum;

          if (round_count == NUM_CYCLES-1) begin
            decrypted_text <= {L_final, R_final};
            state <= FINISH;
          end
          else round_count <= round_count + 1'b1;
        end

        FINISH: begin
          decrypt_busy <= 1'b0;
          decrypt_done <= 1'b1;
          state <= IDLE;
        end

        default: begin
          state <= IDLE;
        end

      endcase
    end
  end

endmodule
