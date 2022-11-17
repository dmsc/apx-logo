# Makefile to generated compressed logo file

# Out output folder
BUILD=build

# Out build tools
MADS=mads
ZX02=zx02

# Programs to build:
PROGS=\
      logo-comp.xex\
      logo-gr8.xex\

all: $(PROGS:%=$(BUILD)/%)


$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.xex: src/%.asm | $(BUILD)
	$(MADS) -i:$(BUILD) -o:$@ $<

$(BUILD)/%.bin: src/%.asm | $(BUILD)
	$(MADS) -i:$(BUILD) -d:BINARY=1 -o:$@ $<

$(BUILD)/%.zx02: $(BUILD)/%.bin | $(BUILD)
	$(ZX02) -f $< $@

$(BUILD)/logo-comp.xex: src/zx02-optim.asm $(BUILD)/logo-gr8.zx02
$(BUILD)/logo-gr8.xex: src/scr8.bin
$(BUILD)/logo-gr8.bin: src/scr8.bin
