/**
 * LED blinking demo program for iCE40UP5k
 */

//`include "pll_60mhz.v"
//`include "pwm.v"

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

always @(posedge clock_12mhz)
begin
    lf_counter <= lf_counter + 1;
end

/*
 * LEDs
 */
assign clock_pwm = lf_counter[5];
assign clock_fading = lf_counter[14];

// Blue LED: permanently off
assign led_blue   = 1;

// Green LED: blinking
//assign led_green  = lf_counter[23];

// Red LED: permanently off
assign led_red = 1;

reg[7:0]  duty_green;
initial   duty_green = 8'b00000000;

pwm_8bit  pwm_led_green(
  clock_pwm,
  duty_green,
  led_green
  );

always @(posedge clock_fading)
begin
  if (direction == 1)
  begin
    if (duty_green == 8'b11111111)
    begin
      direction <= 0;
    end
    else begin
      duty_green <= duty_green + 1;
    end
  end
  else begin
    if (duty_green == 0)
    begin
      direction <= 1;
    end
    else begin
      duty_green <= duty_green - 1;
    end
  end
end

endmodule
