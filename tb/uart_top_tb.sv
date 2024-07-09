
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

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  int         pass;  // number of times results matched
  int         fail;  // number of times results did not match
  
  // Interface instantiation
  uart_intf uart_if();

  // Mailboxes for TX and RX
  mailbox #(uart_trans_t) tx_mbx;
  mailbox #(uart_trans_t) rx_mbx;
  
  // Instantiate the driver
  uart_dvr uart_driver;

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
  
   // Task to display received data
  task display_received_data();
    forever begin
      logic [7:0] received_data;
      rx_mbx.get(received_data);
      $display("Received Data: %c", received_data);
    end
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial
    // Dump VCD file for manual checking
    $dumpfile("dump.vcd");
    $dumpvars;
	// Apply reset
    apply_reset();
    // Start clock
    start_clk();

	display_received_data();
	
    // Initialize the mailboxes
    tx_mbx = new();
    rx_mbx = new();

    // Instantiate the UART driver with the interface and mailboxes
    uart_driver = new(uart_if, tx_mbx, rx_mbx);

    // Start the UART driver
    fork
      uart_driver.run();
    join_none

    @(posedge clk);
    repeat (100) begin
    // Stimulate the TX mailbox with some data
    tx_mbx.put($urandom);
    tx_mbx.put(8'h41); 
    tx_mbx.put(8'h52); 
    tx_mbx.put(8'h54); 
    tx_mbx.put(8'h0A); 
	
	// Monitor TX and RX signals
    $display("Time: %0t | TX: %b | RX: %b", $time, uart_if.tx, uart_if.rx);
	end

    // Delay
    repeat (150) @(posedge clk);
	
    // Print results
    $display("%0d/%0d PASSED", pass, pass+fail);
    // End simulation
    $finish;
  end

endmodule
