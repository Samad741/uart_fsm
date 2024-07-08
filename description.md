Description:
	Here, 8 bit data input and for num_data it will vary from 5 to 8 bit. Parity bit will be 0 if the data is already even parity means there will be an even number of 1’s and parity bit will be 1 if there is odd number of 1’s ib data bit. Stop-2 bit wil define if the count number of stop bit will be 1 or 2. If stop_2 == ‘0 then one stop bit will be used and if stop_2 == ‘1, we have to use 2 stop bit. When the valid and ready signalis 1 at a positive clock edge then data will be captured. 


UART Protocols: Its a set of rules of how we send the data (which component to which component) .It is a half-duplex protocol. - means transferring and receiving the data but not at the same time.

FSM: A controller which generates signals. Here num_data is also included so that we can choose 5 or 6 or 7 or 8 bit data. 

Parity Generator: It is basically a XOR get setup which will give 1 for odd number of 1’s in input data and will give 0 for even number of 1’s in input data.

PISO: Parallel Input Serial Output will take 8 bit input data in parallel and will give serial single data output.

MUX: A 4x1 mux will be used to pass the start bit, data bit, parity bit and stop bit sequentially.
