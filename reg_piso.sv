module reg_piso(
  input logic arst_n,
  input logic clk,

  input logic [2:0] d_reg_sel,
  input logic d_reg_en,
  input logic [7:0] data,

  output logic data_out
  );

  logic [7:0] register;

  always_ff @(posedge clk or negedge arst_n) begin
    if (arst_n == 0) begin
      register = '0;
    end
    else begin
      for (int i = 0; i < 8; i++) begin
        register[i] = data[i];
      end
    end
  end
  always_comb begin
    case(d_reg_sel)
      'b000:   data_out = register[0];
      'b001:   data_out = register[1];
      'b010:   data_out = register[2];
      'b011:   data_out = register[3];
      'b100:   data_out = register[4];
      'b101:   data_out = register[5];
      'b110:   data_out = register[6];
      'b111:   data_out = register[7];
      default: data_out = '0;
    endcase
  end

endmodule

