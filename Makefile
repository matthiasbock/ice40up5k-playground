#
# Makefile to compile Verilog source files
# for iCE40 FPGAs
#
# Author: Matthias Bock <mail@matthiasbock.net>
# License: GNU GPLv3
#

MAIN = main
MAIN_SRC = $(MAIN).v
CLOCK_FREQ = 60
PLL_SRC = pll_$(CLOCK_FREQ)mhz.v
SRCS = $(MAIN_SRC) $(PLL_SRC) pwm.v

FPGA_DIE = 5k
FPGA_PACKAGE = sg48
FPGA_OPTION = -d $(FPGA_DIE) -P $(FPGA_PACKAGE)
PCF = ice40up5k-b-evn.pcf


all: $(MAIN).blif

#
# Compile Verilog source code
#

# Configure PLL tile
pll: $(PLL_SRC)

$(PLL_SRC):
	icepll -i 12 -o $(CLOCK_FREQ) -qmf $@

clean_pll:
	 @rm -f $(PLL_SRC)

# Synthesize netlist with device-specific blocks
$(MAIN).blif: $(SRCS)
	yosys -Q -p "synth_ice40 -blif $@" $^

clean_netlist:
	@rm -f $(MAIN).blif $(MAIN).edif $(MAIN).asc

# Visualize generated networks
show: $(MAIN).pdf
	evince $< &

pdf: $(MAIN).pdf

%.pdf: %.v
	@rm -f ~/.yosys_show.dot ~/.yosys_show2.dot
	yosys -Q -p "read_verilog $(SRCS); hierarchy; select $*; show -format dot -viewer echo;"
	dot -Tpdf ~/.yosys_show.dot > $@

clean_pdf:
	@rm -f $(MAIN).pdf


#
# Place and route
#

asc: $(MAIN).asc

# Place and route
%.asc: %.blif
	arachne-pnr $(FPGA_OPTION) -p $(PCF) $< -o $@

# Bitstream packing
%.bin: %.asc
	#icetime -tmd hx1k $<
	@cp $^ _$^
	icepack $< $@
	@mv _$^ $^

clean_bitstream:
	@rm -f $(MAIN).bin $(MAIN).bit


# Flash onto target
flash: $(MAIN).bin
	iceprog $<

.PHONY: clean clean_pll clean_netlist clean_bitstream clean_pdf
clean: clean_pll clean_netlist clean_bitstream clean_pdf
