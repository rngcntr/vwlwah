# Do not use make's built-in rules and variables
# (this increases performance and avoids hard-to-debug behaviour);
MAKEFLAGS += -r

PACKAGES =\
		  utils
MODULES=\
	  fifo_bb \
	  fifo_32b \
	  fifo_b32 \
	  inverter \
	  encoder \
	  decoder \
	  logic_or \
	  AXIS2FIFO_v1_0 \
	  AXIS2FIFO_v1_0_S00_AXIS \
	  FIFO2AXIS_v1_0 \
	  FIFO2AXIS_v1_0_M00_AXIS \
	  sizedown \
	  sizeup

TESTBENCH=\
	  encoder_big

GHDL_CMD=ghdl

BINDIR=bin

.PHONY: clean dump wave

all: compile

run:
	rm -f wave.ghw
	$(GHDL_CMD) -r $(TESTBENCH) --wave=wave.ghw

compile:
	mkdir -p bin
	$(GHDL_CMD) -i --workdir=$(BINDIR) --std=08 --work=work $(addprefix src/,$(addsuffix .vhdl, $(PACKAGES)))
	$(GHDL_CMD) -i --workdir=$(BINDIR) --std=08 --work=work $(addprefix src/,$(addsuffix .vhdl, $(MODULES)))
	$(GHDL_CMD) -i --workdir=$(BINDIR) --std=08 --work=work $(addprefix tb/,$(addsuffix .vhdl, $(TESTBENCH)))
	$(GHDL_CMD) -m --workdir=$(BINDIR) --std=08 --work=work $(TESTBENCH)

dump:
	rm -f dump
	$(GHDL_CMD) -r $(TESTBENCH) --trace-signals > dump

wave:
	rm -f wave.ghw
	$(GHDL_CMD) -r $(TESTBENCH) --wave=wave.ghw

clean:
	$(GHDL_CMD) --clean --workdir=$(BINDIR)
