module fsm(
  input logic clk,             // Clock input
  input logic arst_n,          // Asynchronous reset (active low)

  input logic [1:0] num_data,  // Number of data bits
  input logic parity,          // Parity bit indicator
  input logic stop_2,          // Stop 2 bit indicator

  input logic valid,           // Valid signal
  output logic ready,          // Ready signal

  output logic d_reg_en,       // Data register enable
  output logic [2:0] d_reg_sel,// Data register select
  output logic [1:0] sel       // Selection signal
  );

  logic [2:0] cntr;            // Counter for data bits
  logic [2:0] pstate, nstate;  // Present and next state declaration
  
  // State enumeration
  typedef enum logic [2:0]{
    IDLE   = 3'b000,           // Idle state
    START  = 3'b001,           // Start state
    DATA   = 3'b010,           // Data state
    PARITY = 3'b011,           // Parity state
    STOP_1 = 3'b100,           // Stop 1 state
    STOP_2 = 3'b101            // Stop 2 state
  } state_t;

  state_t state;               // State variable

  ///////////////////////////////////
  // Next State and Output Logic
  ///////////////////////////////////

  always_comb begin:NSOL
    begin: NSL
      case(pstate)
        IDLE: nstate = valid ? START : IDLE;
        START: nstate = DATA;
        DATA: if ((cntr == {1'b1, num_data}) && parity) 
                      nstate = PARITY;
              else if ((cntr == {1'b1, num_data}) && !parity) 
                      nstate = STOP_1;
              else begin
                      cntr += 1;
                      nstate = DATA;
              end
        PARITY: nstate = STOP_1;
        STOP_1: nstate = stop_2 ? STOP_2 : IDLE;
        STOP_2: nstate = IDLE;
        default: nstate = 3'bx;
      endcase
    end

    // Output Logic
    begin: OL
      case(pstate)
        IDLE: begin
          ready = 1;
          sel = 'b11;
          d_reg_en = 1;
          d_reg_sel = '0;
        end
        START: begin
          ready = 0;
          sel = 'b00;
          d_reg_en = 0;
          d_reg_sel = '0;
        end
        DATA: begin
          ready = 0;
          sel = 'b01;
          d_reg_en = 1;
          d_reg_sel = cntr;
        end
        PARITY: begin
          ready = 0;
          sel = 'b10;
          d_reg_en = 0;
          d_reg_sel = '0;
        end
        STOP_1: begin
          ready = 0;
          sel = 'b11;
          d_reg_en = '0;
          d_reg_sel = '0;
        end
        STOP_2: begin
          ready = 0;
          sel = 'b11;
          d_reg_en = 0;
          d_reg_sel = '0;
        end
        default: begin
          ready = 'bx;
          sel = 'bxx;
          d_reg_en = 'bx;
          d_reg_sel = 'bx;
        end
      endcase
    end
  end

  ////// Present State Register ////////
  always_ff @(posedge clk or negedge arst_n) begin: PSR
    if (arst_n == 0) begin
      cntr <= '0;
      pstate <= IDLE;   // Reset to IDLE state
    end else begin
      pstate <= nstate;       // Update to next state
    end
  end

endmodule

