/*
Testbench of UART TOP  
Author : Shahid Uddin Ahmed (shahidshakib0@gmail.com)
*/

module uart_top_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic arst_n; // active low asynchronous reset
  logic clk; // global clock signal
  logic [7:0] data; // 8-bit input data
  logic [1:0] num_data; // number of data bits
  logic parity; // parity enable signal
  logic stop_2; // 2 stop bits enable signal
  logic valid; // valid signal for UART transmission
  logic ready; // ready signal from UART
  logic Tx; // UART transmit signal

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  int         pass;  // number of times results matched
  int         fail;  // number of times results did not match

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS 
  //////////////////////////////////////////////////////////////////////////////////////////////////
  uart_top u_uart_top (
    .clk(clk),
    .arst_n(arst_n),
    .data(data),
    .num_data(num_data),
    .parity(parity),
    .stop_2(stop_2),
    .valid(valid),
    .ready(ready),
    .Tx(Tx)
  );

  // Driver Mailboxes for Inputs
  mailbox #(logic [7:0]) data_dvr_mbx  = new();
  mailbox #(logic [1:0]) num_data_dvr_mbx  = new();
  mailbox #(logic) parity_dvr_mbx  = new();
  mailbox #(logic) stop_2_dvr_mbx  = new();
  mailbox #(logic) valid_dvr_mbx  = new();

  // Monitor Mailboxes for Inputs and Outputs
  mailbox #(logic [7:0]) data_mon_mbx  = new();
  mailbox #(logic [1:0]) num_data_mon_mbx  = new();
  mailbox #(logic) parity_mon_mbx  = new();
  mailbox #(logic) stop_2_mon_mbx  = new();
  mailbox #(logic) valid_mon_mbx  = new();
  mailbox #(logic) ready_mon_mbx  = new();
  mailbox #(logic) Tx_mon_mbx  = new();
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Apply system reset and initialize all inputs
  task static apply_reset();
    #100ns;
    clk        <= '0;
    arst_n     <= '0;
    data       <= '0;
    num_data   <= '0;
    parity     <= '0;
    stop_2     <= '0;
    valid      <= '0;
    #100ns;
    arst_n     <= '1;
    #100ns;
  endtask

  // Start toggling system clock forever every 5ns
  task static start_clk();
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
        logic [1:0] tem_num_data;
        logic       tem_parity;
        logic       tem_stop_2;
        logic       tem_valid;
        
        data_dvr_mbx.get(tem_data);
        num_data_dvr_mbx.get(tem_num_data);
        parity_dvr_mbx.get(tem_parity);
        stop_2_dvr_mbx.get(tem_stop_2);
        valid_dvr_mbx.get(tem_valid);

        data <= tem_data;
        num_data <= tem_num_data;
        parity <= tem_parity;
        stop_2 <= tem_stop_2;
        valid <= tem_valid;
        
        @(posedge clk);
      end
  
      forever begin // in monitor
        @ (posedge clk);
        data_mon_mbx.put(data);
        num_data_mon_mbx.put(num_data);
        parity_mon_mbx.put(parity);
        stop_2_mon_mbx.put(stop_2);
        valid_mon_mbx.put(valid);
      end

      forever begin // out monitor
        @ (posedge clk);
        ready_mon_mbx.put(ready);
        Tx_mon_mbx.put(Tx);
      end
      
      forever begin // Scoreboard
        logic expected_ready;
        logic expected_Tx;
        
        ready_mon_mbx.get(expected_ready);
        Tx_mon_mbx.get(expected_Tx);

        // Implement your expected behavior comparison here.
        // This is an example comparison, modify it according to your expected results
        if (expected_ready == ready && expected_Tx == Tx) begin
          pass++;
        end else begin
          fail++;
        end
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
    start_clk();
    // Apply reset
    apply_reset();
    // Start all the verification components
    driver_monitor_scoreboard();
    // Generate random data inputs
    @(posedge clk);
    repeat (100) begin
      data_dvr_mbx.put($urandom);
      num_data_dvr_mbx.put($urandom % 4);
      parity_dvr_mbx.put($urandom % 2);
      stop_2_dvr_mbx.put($urandom % 2);
      valid_dvr_mbx.put($urandom % 2);
    end
    // Delay
    repeat (150) @(posedge clk);
    // Print results
    $display("%0d/%0d PASSED", pass, pass+fail);
    // End simulation
    $finish;
  end

endmodule

