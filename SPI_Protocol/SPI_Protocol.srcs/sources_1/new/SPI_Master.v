module SPI_Master(
    input clk,              // clock signal
    input reset,            // reset
    
    input miso,             // input data from slave
    output mosi,            // output data sent to slave
    output sclk,            // generated clock from freq_divider used for all modules
    output cs,
    
    input [2:0] select,     // selects the clock divisor
    input ready_state,      // starts data transmission
    input pl,               // paralel load
    input [7:0] data_in,    // used only when pl on high         
    output [7:0] data_out   // used for debug
);
    
    wire [3:0] out_cnt; //output from counter
    
    wire enable;

   freq_divider_MUX freq_inst(
    .clk(clk),                //input
    .select(select),         //input
    .sclk(sclk)              //output
   );
   
  
   
   shift_register_master shift_m(
         .clk(sclk),                     //input
         .reset(reset),                  //input
         .enable(enable),                //input
         .miso(miso),                    //input
         .pl(pl),                        //input
         .data_in(data_in),              //input
         .mosi(mosi),                    //output
         .data_out(data_out)             //output
   );
   
   counter cnt_m(
        .clk(sclk),                      //input
        .reset(reset),                   //input
        .enable(enable),                 //input
        .out_cnt(out_cnt)                //output
    );
   
   
    fsm_master fsm_m(
        .clk(sclk),                      //input
        .reset(reset),                   //input
        .ready_state(ready_state),       //input
        .bit_cnt(out_cnt),               //input
        .enable(enable)                  //output
    );
   
    assign cs = ready_state;

endmodule
