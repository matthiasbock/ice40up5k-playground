
module pwm_8bit(
  input clock,
  //input reset,

  input[7:0] duty_cycle,

  output pwm
  );

reg[7:0]  counter;
initial   counter = 0;

always@(posedge clock)
begin
  counter = counter + 1;
  // 0: LED on, 1: LED off
  pwm <= (counter > duty_cycle) ? 1 : 0;
end

endmodule
