/**
 * LED blinking demo program for iCE40UP5k
 */

//`include "pll_60mhz.v"

module top(
    // clockwork FPGA
    input  clock_12mhz,
    //input  reset,

    // LED outputs
    output led_blue,
    output led_red,
    output led_green
    );

/*
 * High frequency clock
 */
wire pll_in = clock_12mhz;
wire pll_out;
wire locked;
pll pll_36mhz(
    pll_in,
    pll_out,
    locked
    );
wire    reset;
assign  reset = !locked;
wire    hf_clock;
assign  hf_clock = pll_out & locked;

/*
 * High frequency counter
 */
reg[7:0]  pll_counter;
initial   pll_counter = 0;

always @(posedge reset, posedge clock_12mhz)
begin
    if (reset)
    begin
        // reset counter
        pll_counter <= 0;
    end
    else begin
        if (pll_counter > 128)
        begin
            led_blue <= 1;
        end
        else begin
            led_blue <= 0;
        end
    end
end

endmodule
