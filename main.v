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
    output led_green,

    output pwm1
    );

/*
 * High frequency clock
 */
wire pll_in = clock_12mhz;
wire pll_out;
wire locked;
pll pll_hf_clock(
    pll_in,
    pll_out,
    locked
    );
//wire    reset;
//assign  reset = !locked;
wire    hf_clock;
assign  hf_clock = pll_out & locked;

/*
 * Low frequency clock: 1.5 kHz
 */
reg[23:0]   lf_counter;
initial     lf_counter = 0;

assign led_blue   = 1;
assign led_green  = lf_counter[23];
assign led_red    = 1;

reg[7:0]  duty_red;

always @(posedge clock_12mhz)
begin
    lf_counter <= lf_counter + 1;
end

endmodule
