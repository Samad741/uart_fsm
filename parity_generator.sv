module parity_generator(
  input logic [0:1] num_data,
  input logic [0:7] data,
  output logic parity_bit	
);

  assign parity_bit = ((data[0] ^ data[1])^(data[2] ^ data[3]))^((data[4] ^ (data[5] & (num_data[0] | num_data[1])))^((data[6] & num_data[1]) ^ (data[7] & (num_data[0] & num_data[1]))));
endmodule

