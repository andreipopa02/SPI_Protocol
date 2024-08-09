//Clock frequency divider
module freq_divider_MUX(
    input clk,                           // clock signal
    input [2:0] select,                  // 2-bit select divisor
    
    output reg sclk                      //new generated clock
);
    reg [27:0] counter = 28'd0;          // counter 
    reg [27:0] divisor;                  // register to hold the selected divisor

    always @(*) begin
        case (select)
            3'b000: divisor = 28'd2;               // select DIVISOR = 2
            3'b001: divisor = 28'd4;               // select DIVISOR = 4
            3'b010: divisor = 28'd8;               // select DIVISOR = 8
            3'b011: divisor = 28'd16;              // select DIVISOR = 16
            3'b100: divisor = 28'd64;              // select DIVISOR = 64
            3'b101: divisor = 28'd128;             // select DIVISOR = 128
            3'b110: divisor = 28'd256;             // select DIVISOR = 256
            3'b111: divisor = 28'd100_000_000;     // select DIVISOR = 100_000_000
            default: divisor = 28'd100_000_000;    // default case
        endcase
    end

    always @(posedge clk) begin           
        counter <= counter + 28'd1;       
        
        if (counter >= (divisor - 1)) begin             // if counter reaches the divisor value
            counter <= 28'd0;                           // reset counter to 0
        end
        sclk <= (counter < divisor/2) ? 1'b1 : 1'b0;    // set output signal
    end
endmodule


//Clock frequency divider
module freq_divider(
    input clk,                                  // clock signal
    
    output reg sclk                             // new generated clock
);
    reg [27:0] counter = 28'd0;                 // counter 
    reg [27:0] divisor = 28'd100_000_000;       // register to hold the selected divisor

    always @(posedge clk) begin           
        counter <= counter + 28'd1;       
        
        if (counter >= (divisor - 1)) begin          // if counter reaches the divisor value
            counter <= 28'd0;                        // reset counter to 0
        end
        sclk <= (counter < divisor/2) ? 1'b1 : 1'b0; // set output signal
    end
endmodule


// Counter Module
module counter(
    input clk,                             // clock signal
    input reset,                           // reset
    input enable,                          // enable counting
    
    output reg [3:0] out_cnt               // output
);
    always @(posedge clk or posedge reset) begin           
        if(reset)
            out_cnt <= 4'b0000 ;
        else if (enable) begin                  
            if (out_cnt == 4'b1000)        
                out_cnt <= 0;              
            else
                out_cnt <= out_cnt + 1;    
        end
    end
endmodule

//Sfhift register module for master
module shift_register_master(
    input clk,                             // clock signal
    input reset,                           // reset
    input enable,                          // enable shifting
    input miso,                            // input from slave
    input pl,                              // paralel load control signal
    input [7:0] data_in,                   // paralel load data
    output reg mosi,                       // output
    output reg [7:0] data_out              // signal used for debug and display on board
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 8'b0;
            mosi <= 1'b0;
        end 
        else if(pl) begin
            data_out= data_in;
        end 
        else if (enable) begin
            data_out <= {data_out[6:0], miso};
            mosi <= data_out[7];           // assign the MSB to the output
        end
    end
endmodule

//FSM module for master
module fsm_master(
    input clk,                              // clock signal
    input reset,                            // reset
    input ready_state,                      // start the data transmission process
    input [3:0] bit_cnt,                    // input from counter
    
    output reg enable                       // control signal used for enabling the counter & shift register
);
    // State definitions
    parameter IDLE = 2'b00,                 // waits for ready_state to go to next state
              TRANSFER = 2'b01;             // enable the counter and shift register and start data transmission
              
    reg [1:0] state;
    reg [1:0] next_state;
   

    always @(posedge clk) begin
        if (reset) 
            state = IDLE;
        else 
            state = next_state;
            
        case (state)
            IDLE: begin
                enable = 0;
                if (ready_state) 
                    next_state = TRANSFER;
                else
                    next_state = IDLE;
            end
            
            TRANSFER: begin
               enable = 1;
               if (bit_cnt == 4'b1000) begin
                  enable = 0;
                  next_state = IDLE;
               end
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule


//Sfhift register module for slave
module shift_register_slave(
    input clk,                             // clock signal
    input reset,                           // reset
    input enable,                          // enable shifting
    input mosi,                            // input from master
    input pl,                              // paralel load control signal
    input [7:0] data_in,                   // paralel load data
    output reg miso,                       // output
    output reg [7:0] data_out              // signal used for debug and display on board
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 8'b0;
            miso <= 1'b0;
        end 
        else if(pl) begin
            data_out= data_in; 
        end 
        else if (enable) begin
            data_out <= {data_out[6:0], mosi};
            miso <= data_out[7];           // assign the MSB to the output
        end
    end
endmodule


//FSM module for slave
module fsm_slave(
    input clk,                              // clock signal
    input reset,                            // reset
    input cs,                               // start the data transmission process
    input [3:0] bit_cnt,                    // input from counter
    
    output reg enable                       // control signal used for enabling the counter
);
    // State definitions
    parameter IDLE = 2'b00,                 // waits for ready_state to go to next state
              TRANSFER = 2'b01;             // enable the counter and shift register and start transmission
              
    reg [1:0] state;
    reg [1:0] next_state;
   

    always @(posedge clk) begin
        if (reset) 
            state = IDLE;
        else 
            state = next_state;
            
        case (state)
            IDLE: begin
                enable = 0;
                if (cs) 
                    next_state = TRANSFER;
                else
                    next_state = IDLE;
            end
            
            TRANSFER: begin
               enable = 1;
               if (bit_cnt == 4'b1000) begin
                    enable = 0;
                    next_state = IDLE;
               end
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule