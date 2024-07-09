module reg_piso(
  input logic arst_n, // active low asynchronous reset
  input logic clk, // global clock signal

  input logic [2:0] d_reg_sel, // 3-bit select signal to choose which bit to output
  input logic d_reg_en, // enable signal for register
  input logic [7:0] data, // 8-bit input data

  output logic data_out // single bit output data
  );

  logic [7:0] register; // internal 8-bit register to store data

  always_ff @(posedge clk or negedge arst_n) begin
    if (arst_n == 0) begin // check if reset is active (low)
      register = '0; // if reset is active, clear the register
    end
    else begin
      for (int i = 0; i < 8; i++) begin // loop to store input data into register
        register[i] = data[i]; // assign each bit of input data to the register
      end
    end
  end
  
  always_comb begin
    case(d_reg_sel) // select the output bit based on d_reg_sel
      'b000:   data_out = register[0]; // output bit 0 of register
      'b001:   data_out = register[1]; // output bit 1 of register
      'b010:   data_out = register[2]; // output bit 2 of register
      'b011:   data_out = register[3]; // output bit 3 of register
      'b100:   data_out = register[4]; // output bit 4 of register
      'b101:   data_out = register[5]; // output bit 5 of register
      'b110:   data_out = register[6]; // output bit 6 of register
      'b111:   data_out = register[7]; // output bit 7 of register
      default: data_out = '0; // default case 
    endcase
  end

endmodule

