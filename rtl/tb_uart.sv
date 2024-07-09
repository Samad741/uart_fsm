// tb_uart.sv
import verif_pkg::*; // Import the verification package

module tb_uart;

  // Interface instantiation
  uart_intf uart_if();

  // Mailboxes for TX and RX
  mailbox #(uart_trans_t) tx_mbx;
  mailbox #(uart_trans_t) rx_mbx;

  // Instantiate the driver
  uart_dvr uart_driver;

  initial begin
    // Initialize the mailboxes
    tx_mbx = new();
    rx_mbx = new();

    // Instantiate the UART driver with the interface and mailboxes
    uart_driver = new(uart_if, tx_mbx, rx_mbx);

    // Configure the UART
    assert(uart_driver.set_baud(9600)) else $fatal("Failed to set baud rate");
    assert(uart_driver.set_d_length(8)) else $fatal("Failed to set data length");
    assert(uart_driver.set_parity(1)) else $fatal("Failed to set parity");
    assert(uart_driver.set_stop(1)) else $fatal("Failed to set stop bits");

    // Start the UART driver
    fork
      uart_driver.run();
    join_none

    // Monitor TX and RX signals
    $monitor("Time: %0t | TX: %b | RX: %b", $time, uart_if.tx, uart_if.rx);

    // Stimulate the TX mailbox with some data
    tx_mbx.put(8'h55); // ASCII for 'U'
    tx_mbx.put(8'h41); // ASCII for 'A'
    tx_mbx.put(8'h52); // ASCII for 'R'
    tx_mbx.put(8'h54); // ASCII for 'T'
    tx_mbx.put(8'h0A); // Newline

    // Wait for a while to see the results
    #1000;
    $finish;
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

