module parity_generator(
  input logic [0:1] num_data, // 2-bit input to determine the number of data bits used
  input logic [0:7] data, // 8-bit input data
  output logic parity_bit // output parity bit
);

  // The parity bit is calculated as the XOR of selected data bits.
  // The number of data bits used is determined by num_data:
  // - num_data = 00: Use data[0] to data[4]
  // - num_data = 01: Use data[0] to data[5]
  // - num_data = 10: Use data[0] to data[6]
  // - num_data = 11: Use data[0] to data[7]
  assign parity_bit = ((data[0] ^ data[1]) ^ (data[2] ^ data[3])) ^
                      ((data[4] ^ (data[5] & (num_data[0] | num_data[1]))) ^
                       ((data[6] & num_data[1]) ^ (data[7] & (num_data[0] & num_data[1]))));

  //////////DESCRIPTION////////
  // The parity bit is the XOR of the input data bits. The number of data bits 
  // considered varies based on the value of num_data:
  //
  // - num_data = 00 (2'b00):
  //   Only data[0] to data[4] are used. The bits data[5], data[6], and data[7] 
  //   contribute 0 to the parity calculation due to the AND operation with 0.
  //
  // - num_data = 01 (2'b01):
  //   Bits data[0] to data[5] are used. Data[6] is ANDed with num_data[1] (which is 0), 
  //   making data[6] contribute 0 to the parity calculation. Data[7] is also 0.
  //
  // - num_data = 10 (2'b10):
  //   Bits data[0] to data[6] are used. Data[7] is ANDed with the AND of num_data[0] 
  //   and num_data[1] (num_data[0] & num_data[1]), making data[7] contribute 0 to the 
  //   parity calculation.
  //
  // - num_data = 11 (2'b11):
  //   All bits data[0] to data[7] are used for the parity calculation.

endmodule

