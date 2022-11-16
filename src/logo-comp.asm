;
; Test module for 6502 ZX02 decompressors
; ---------------------------------------
;
; Test for small+fast decompressor
;
	org	$2b00

out_addr = $2000

	icl	"zx02-optim.asm"

start:
        jsr     full_decomp
        jmp     $2a31

comp_data
        ins  "logo-gr8.zx02"

	ini	start

