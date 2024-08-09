module SPI(
    input clk,                              // board clock
    input reset,                            // reset
    input [2:0] select,                     // select clock speed
    input ready_state,                      // start data transmission
    input pl,                               // load data into shift registers
    
    input [7:0]data_in_master,              // input from switches
    input [7:0]data_in_slave,               // input from switches
    
    output [7:0]data_out_master,            // output for board leds
    output [7:0]data_out_slave              // output for board leds
    
    );
    
    wire sclk;
    wire cs;
    
    wire miso;
    wire mosi;
    
    SPI_Master master(
        .clk(clk),
        .reset(reset),
        .miso(miso),
        .mosi(mosi),
        .select(select),
        .ready_state(ready_state),
        .pl(pl),
        .data_in(data_in_master),
        .data_out(data_out_master),
        .sclk(sclk),
        .cs(cs)
    );
    
    
    SPI_Slave slave(
        .sclk(sclk),
        .reset(reset),
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .pl(pl),
        .data_in(data_in_slave),
        .data_out(data_out_slave)
    );
    
endmodule