module uart_top(
  input logic clk,
  input logic arst_n,
  
  input logic [7:0] data,
  input logic [1:0] num_data,
  input logic parity,
  input logic stop_2,

  input logic valid,
  output logic ready,
  output logic Tx
  );

  logic mux_in1, mux_in2;
  logic [1:0] mux_sel;

  fsm dut_fsm(
    .clk(clk),
    .arst_n(arst_n),
    .num_data(num_data),
    .parity(parity),
    .stop_2(stop_2),
    .valid(valid),
    .ready(ready),
    .d_reg_en(dut_reg_piso.d_reg_en),
    .d_reg_sel(dut_reg_piso.d_reg_sel),
    .sel(mux_sel)
  );

  reg_piso dut_reg_piso(
    .clk(clk),
    .arst_n(arst_n),
    .data(data),
    .d_reg_en(dut_fsm.d_reg_en),
    .d_reg_sel(dut_fsm.d_reg_sel),
    .data_out(mux_in1)
  );

  parity_generator dut_parity_generator(
    .num_data(num_data),
    .data(data),
    .parity_bit(mux_in2)
);
  assign Tx = (mux_sel == 2'b00) ? '0 : 
              (mux_sel == 2'b01) ? mux_in1 : 
              (mux_sel == 2'b10) ? mux_in2 : '1;

endmodule


