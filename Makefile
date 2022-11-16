# Makefile to generated compressed logo file

# Out output folder
BUILD=build

# Out build tools
MADS=mads
ACOM=ataricom
ZX02=zx02


all: $(BUILD)/logo-comp.xex


$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.xex: src/%.asm | $(BUILD)
	$(MADS) -i:$(BUILD) -o:$@ $<

$(BUILD)/%.bin: $(BUILD)/%.xex | $(BUILD)
	$(ACOM) -b 1 -n $< $@

$(BUILD)/%.zx02: $(BUILD)/%.bin | $(BUILD)
	$(ZX02) -f $< $@

$(BUILD)/logo-comp.xex: src/zx02-optim.asm $(BUILD)/logo-gr8.zx02
$(BUILD)/logo-gr8.xex: src/scr8.bin
