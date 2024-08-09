
module tb_top();
    reg clk;
    reg reset;
    reg [2:0]select;
    reg ready_state;
    reg pl;
    reg [7:0]data_in_master;
    reg [7:0]data_in_slave;
    
    wire [7:0]data_out_master;
    wire [7:0]data_out_slave;
    
    SPI spi(
        .clk(clk),
        .reset(reset),
        .select(select),
        .ready_state(ready_state),
        .pl(pl),
        .data_in_master(data_in_master),
        .data_in_slave(data_in_slave),
        .data_out_master(data_out_master),
        .data_out_slave(data_out_slave)
    );
    
     always begin
        #5 clk = ~clk;  // 100 MHz clock
     end
    
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        select = 3'b000;
        ready_state = 0;
        pl = 0;
        data_in_master = 8'b1001_1001;
        data_in_slave = 8'b0110_0110;
        
        

        #20 reset = 0; pl = 1;
        #20 pl =0;
        #10 ready_state =1;
        #60 ready_state =0;
        
        #200 
        #20 reset = 0;
        #20 pl =0;
        #10 ready_state =1;
        #60 ready_state =0;
       
        #300
        $finish;
    end

    
endmodule
