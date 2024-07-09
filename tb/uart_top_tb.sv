`include "../inc/verif_pkg.sv" 
import verif_pkg::*; // Import the verification package

module uart_top_tb;

  // Signals
  logic clk; // global clock signal
  logic arst_n; // active low asynchronous reset
  logic [7:0] data; // 8-bit input data
  logic [1:0] num_data; // number of data bits
  logic parity; // parity enable signal
  logic stop_2; // 2 stop bits enable signal
  logic valid; // valid signal for UART transmission
  logic ready; // ready signal from UART
  logic Tx; // UART transmit signal
  
  // Interface instantiation
  uart_intf uart_if();

  // Mailboxes for TX and RX
  mailbox #(uart_trans_t) tx_mbx;
  mailbox #(uart_trans_t) rx_mbx;

  // Instantiate the Rtl
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

  // Instantiate the driver
  uart_dvr uart_driver;

  initial begin
    // Initialize the mailboxes
    tx_mbx = new();
    rx_mbx = new();

    // Instantiate the UART driver with the interface and mailboxes
    uart_driver = new(uart_if, tx_mbx, rx_mbx);

    // Start the UART driver
    fork
      uart_driver.run();
    join_none

    // Monitor TX and RX signals
    $monitor("Time: %0t | TX: %b | RX: %b", $time, uart_if.tx, uart_if.rx);

    // Stimulate the TX mailbox with some data
    tx_mbx.put($urandom);
    tx_mbx.put(8'h41); 
    tx_mbx.put(8'h52); 
    tx_mbx.put(8'h54); 
    tx_mbx.put(8'h0A); 

    // Wait for a while to see the results
    #1000;
    $stop;
  end

  // Task to display received data
  task display_received_data();
    forever begin
      logic [7:0] received_data;
      rx_mbx.get(received_data);
      $display("Received Data: %c", received_data);
    end
  endtask

  initial begin
    fork
      display_received_data();
    join_none
  end

endmodule