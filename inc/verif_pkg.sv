package verif_pkg;

    typedef logic [7:0] uart_trans_t;

    ////////////////////////////////////////////////////////////////////////////
    // UART
    ////////////////////////////////////////////////////////////////////////////

    class uart_base;

        int baud_rate = 115200;
        int data_len  = 8;
        int num_stop  = 1;
        int parity    = 0;

        logic tx_clk;
        logic rx_clk;
        bit tx_clk_active;
        bit rx_clk_active;

        virtual uart_intf intf;

        mailbox #(uart_trans_t) tx_mbx;
        mailbox #(uart_trans_t) rx_mbx;

        function automatic bit set_baud(int rate);
            if (tx_clk_active || rx_clk_active) return 0;
            else begin
                baud_rate = rate;
            end
            return 1;
        endfunction

        function automatic bit set_parity( int par);
            if (tx_clk_active || rx_clk_active) return 0;
            else begin
                parity = par;
            end
            return 1;
        endfunction

        function automatic bit set_d_length( int len);
            if (tx_clk_active || rx_clk_active) return 0;
            else begin
                if(len>8 || len<5) $fatal(1,"Invalid Data Length");
                data_len = len ;
            end
            return 1;
        endfunction

        function automatic bit set_stop( int sb);
            if (tx_clk_active || rx_clk_active) return 0;
            else begin
                if(sb>2 || sb <1) $fatal(1,"Invalid Stop Bit Length");
                num_stop = sb;
            end
            return 1;
        endfunction

        function automatic bit cal_parity(bit [7:0] data);
            bit is_odd;
            for (int i = 0; i < data_len; i++) if (data[i]) is_odd++;
            case (parity)
                'b01    : return is_odd;
                'b10    : return ~is_odd;
                default : return 0;
            endcase
        endfunction

        `define XX_CLK(__T__)                                   \
            task automatic activate_``__T__``_clk();            \
                realtime time_period;                           \
                time_period = 1s/baud_rate;                     \
                ``__T__``_clk_active = 1;                       \
                while (``__T__``_clk_active) begin              \
                    ``__T__``_clk <= '1; #(time_period/2);      \
                    ``__T__``_clk <= '0; #(time_period/2);      \
                end                                             \
            endtask                                             \


        `XX_CLK(tx)
        `XX_CLK(rx)

        function new(virtual uart_intf intf, mailbox #(uart_trans_t) tx_mbx, mailbox #(uart_trans_t) rx_mbx);
            this.intf    = intf;
            this.tx_mbx  = tx_mbx;
            this.rx_mbx  = rx_mbx;
        endfunction

    endclass

    string string_buffer;

    class uart_dvr extends uart_base;

        function new(virtual uart_intf intf, mailbox #(uart_trans_t) tx_mbx, mailbox #(uart_trans_t) rx_mbx);
            super.new(intf, tx_mbx, rx_mbx);
        endfunction

        task automatic run();
            string_buffer = "";
            fork
                forever begin
                    logic [7:0] data;
                    tx_mbx.peek(data);
                    fork
                        activate_tx_clk();
                        begin
                            @(posedge tx_clk) intf.tx <= '0;
                            for (int i = 0; i < data_len; i++) begin
                                @(posedge tx_clk);
                                intf.tx <= data[i];
                            end
                            if (parity) begin
                                @(posedge tx_clk);
                                intf.tx <= cal_parity(data);
                            end
                            repeat(num_stop) begin
                                @(posedge tx_clk);
                                intf.tx <= '1;
                            end
                            @(posedge tx_clk);
                            tx_clk_active = 0;
                        end
                    join
                    tx_mbx.get(data);
                end
                forever begin
                    logic [7:0] data;
                    rx_mbx.peek(data);
                    data = 0;
                    @ (negedge intf.rx);
                    fork
                        activate_rx_clk();
                        begin
                            @(negedge rx_clk);
                            for (int i = 0; i < data_len; i++) begin
                                @(negedge rx_clk);
                                data[i] = intf.rx;
                            end
                            if(parity) @(negedge rx_clk);
                            repeat (num_stop) @(negedge rx_clk);
                            if (data == "\n") begin
                                $display("\033[1;33mUART RX:\033[0m%s",string_buffer);
                                string_buffer = "";
                            end
                            rx_clk_active = 0;
                        end
                    join
                    rx_mbx.get(data);
                end
            join_none
        endtask

    endclass

endpackage

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

interface uart_intf;
    logic tx;
    logic rx;
endinterface
