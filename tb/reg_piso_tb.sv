/*
Testbench of PISO register
Author : Shahid Uddin Ahmed (shahidshakib0@gmail.com)
*/

module reg_piso_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic arst_n; // active low asynchronous reset
  logic clk; // global clock signal
  logic [2:0] d_reg_sel; // 3-bit select signal to choose which bit to output
  logic d_reg_en; // enable signal for register
  logic [7:0] data; // 8-bit input data
  logic data_out; // single bit output data

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  int pass;  // number of times results matched
  int fail;  // number of times results did not match
  logic [7:0] u_register; // internal 8-bit register to store data

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  reg_piso u_reg_piso (
    .clk(clk),
    .arst_n(arst_n),
    .d_reg_en(d_reg_en),
    .d_reg_sel(d_reg_sel),
    .data(data),
    .data_out(data_out)
  );

  // Driver Mailbox for Inputs
  mailbox #(logic [7:0]) data_dvr_mbx  = new();
  mailbox #(logic) d_reg_en_dvr_mbx  = new();
  mailbox #(logic [2:0]) d_reg_sel_dvr_mbx  = new();

  // Monitor Mailbox For Inputs and Outputs
  mailbox #(logic [7:0]) data_mon_mbx  = new();
  mailbox #(logic) d_reg_en_mon_mbx  = new();
  mailbox #(logic [2:0]) d_reg_sel_mon_mbx  = new();
  mailbox #(logic) data_out_mon_mbx  = new();

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Apply system reset and initialize all inputs
  task static apply_reset();
    #100ns;
    clk        <= '0;
    arst_n     <= '0;
    d_reg_sel  <= '0;
    d_reg_en   <= '0;
    data       <= '0;
    u_register <= '0;
    #100ns;
    arst_n     <= '1;
    #100ns;
  endtask

  // Start toggling system clock forever every 5ns
  task static start_clk_i();
    fork
      forever begin
        clk <= '1;
        #5ns;
        clk <= '0;
        #5ns;
      end
    join_none
  endtask

  // Driver, monitor and scoreboard representation
  task static driver_monitor_scoreboard();
    fork
      forever begin // in driver

        logic [7:0] tem_data;
        logic       tem_d_red_en;
        logic [2:0] tem_d_reg_sel;

        data_dvr_mbx.get(tem_data);
        d_reg_en_dvr_mbx.get(tem_d_red_en);
        d_reg_sel_dvr_mbx.get(tem_d_reg_sel);

        data <= tem_data;
        d_reg_en <= tem_d_red_en;
        d_reg_sel <= tem_d_reg_sel;

        @(posedge clk);
      end

      forever begin // in monitor
        @ (posedge clk);
        data_mon_mbx.put(data);
        d_reg_en_mon_mbx.put(d_reg_en);
        d_reg_sel_mon_mbx.put(d_reg_sel);
      end

      forever begin // out monitor
        @ (posedge clk);
        data_out_mon_mbx.put(data_out);

      end

      forever begin // Scoreboard start
        logic [7:0] expected_data;
        logic expected_d_reg_en;
        logic [2:0] expected_d_reg_sel;
        logic expected_data_out;

        logic dut_data_out; 
        
        data_mon_mbx.get(expected_data);
        d_reg_en_mon_mbx.get(expected_d_reg_en);
        d_reg_sel_mon_mbx.get(expected_d_reg_sel);
        
        data_out_mon_mbx.get(dut_data_out);

        if (expected_d_reg_en) begin
          if (expected_d_reg_sel == 3'b000) expected_data_out = expected_data[0];
          else if (expected_d_reg_sel == 3'b001) expected_data_out = expected_data[1];
          else if (expected_d_reg_sel == 3'b010) expected_data_out = expected_data[2];
          else if (expected_d_reg_sel == 3'b011) expected_data_out = expected_data[3];
          else if (expected_d_reg_sel == 3'b100) expected_data_out = expected_data[4];
          else if (expected_d_reg_sel == 3'b101) expected_data_out = expected_data[5];
          else if (expected_d_reg_sel == 3'b110) expected_data_out = expected_data[6];
          else if (expected_d_reg_sel == 3'b111) expected_data_out = expected_data[7];
          else expected_data_out = '0;
        end else begin
          expected_data_out = '0;
        end

        if (expected_data_out == dut_data_out) pass++;
        else fail++;
      end
    join_none

  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial
    // Dump VCD file for manual checking
    $dumpfile("dump.vcd");
    $dumpvars;
    // Start clock
    start_clk_i();
    // Apply reset
    apply_reset();
    // Start all the verification components
    driver_monitor_scoreboard();
    // generate random data inputs
    @(posedge clk);
    repeat (100) begin
      data_dvr_mbx.put($urandom);
      d_reg_en_dvr_mbx.put($urandom);
      d_reg_sel_dvr_mbx.put($urandom);
    end
    // Delay
    repeat (150) @(posedge clk);
    // print results
    $display("%0d/%0d PASSED", pass, pass+fail);
    // End simulation
    $finish;
  end

endmodule

