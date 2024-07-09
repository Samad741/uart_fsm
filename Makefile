FILES += rtl/fsm.sv
FILES += rtl/reg_piso.sv
FILES += rtl/parity_generator.sv
FILES += rtl/uart_top.sv
FILES += tb/uart_top_tb.sv
TOP      += uart_top_tb

vivado: clean
	    xvlog -sv ${FILES} 
		xelab ${TOP} -s top
	    xsim top -runall

clean:
	    @rm -rf top.wdb xsim.dir *.log *.pb *.jou *.vcd

.PHONY: vivado clean
