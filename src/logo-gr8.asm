save_a          = $F7
save_x          = $F8
save_y          = $F9
save_dl         = $FA
RTCLOK          = $14


VDSLST  = $0200         ;DISPLAY LIST NMI VECTOR
VVBLKI  = $0222         ;IMMEDIATE VERTICAL BLANK NMI VECTOR
SDMCTL  = $022F         ;SAVE DMACTL REGISTER
SDLSTL  = $0230         ;SAVE DISPLAY LIST LOW BYTE
GPRIOR  = $026F         ;GLOBAL PRIORITY CELL

PCOLR0  = $02C0         ;1-byte player-missile 0 color/luminance
PCOLR1  = $02C1         ;1-byte player-missile 1 color/luminance
PCOLR2  = $02C2         ;1-byte player-missile 2 color/luminance
PCOLR3  = $02C3         ;1-byte player-missile 3 color/luminance
COLOR0  = $02C4         ;1-byte playfield 0 color/luminance
COLOR1  = $02C5         ;1-byte playfield 1 color/luminance
COLOR2  = $02C6         ;1-byte playfield 2 color/luminance
COLOR3  = $02C7         ;1-byte playfield 3 color/luminance
COLOR4  = $02C8         ;1-byte background color/luminance

CHACT   = $02F3         ;CHACTL REGISTER RAM
CHBAS   = $02F4         ;CHBAS REGISTER RAM

PAL             = $D014
HPOSP0          = $D000
TRIG0           = $D010
TRIG1           = $D011
COLPM0          = $D012
COLPM1          = $D013
COLPM2          = $D014
COLPM3          = $D015
COLPF0          = $D016
COLPF1          = $D017
COLPF2          = $D018
COLPF3          = $D019
COLBK           = $D01A
PRIOR           = $D01B
GRACTL          = $D01D
CONSOL          = $D01F
SKSTAT          = $D20F
WSYNC           = $D40A
NMIEN           = $D40E


        org     $2000

STARTUP lda     RTCLOK
L2C02   cmp     RTCLOK
        beq     L2C02
        sei

        ; store current display-list
        mwa     SDLSTL  save_dl

        mwa     #DLI    VDSLST
        mwa     #DLIST  SDLSTL

        lda     PAL
        and     #8
        tay
        bne     IS_NTSC
        ; Fixup DLI for PAL
        lda     #$36
        sta     DLI_COLPF2
        lda     #$2A
        sta     DLI_COLPF1
        lda     #$60
        sta     DLI_COLBK
IS_NTSC
        ldx     #8
SCLR    lda     COLORS, y
        sta     PCOLR0, x
        iny
        dex
        bpl     SCLR

        lda     #$01
        sta     GPRIOR
        lda     #$3D
        sta     SDMCTL

        lda     #$C0
        sta     NMIEN
        cli

SHOWLOOP
        lda     CONSOL
        and     TRIG0
        and     TRIG1
        beq     EXIT
        lda     SKSTAT
        and     #$04
        bne     SHOWLOOP

EXIT
        sta     GRACTL
        tax
CLRGTIA
        sta     HPOSP0,x
        inx
        bne     CLRGTIA
        lda     #$40
        sta     NMIEN

        ; Restore original display list
        mwa     save_dl SDLSTL
        rts

DLIST   .byte   $70,$70,$70,$70,$60,$4F
        .word   SCREEN
        :60 .byte 15
        .byte   $50
        :11 .byte 15
        .byte   $D0
        .byte   15, 15
        :29     dta $4F, a(REPLINE), $0F
        dta     $4F, a(REPLINE)
        .byte   $41
        .word   DLIST

SCREEN
        ins     'scr8.bin',+1248,1952
        ins     'scr8.bin',+3392,352
REPLINE
        ins     'scr8.bin',+3936,64

DLI     pha
        lda     #$81
        sta     WSYNC
        sta     PRIOR
DLI_COLPF2 = * + 1
        lda     #$46    ; $36
        sta     COLPF2
DLI_COLPF1 = * + 1
        lda     #$3A    ; $2A
        sta     COLPF1
DLI_COLBK = * + 1
        lda     #$72    ; $62
        sta     COLBK
        pla
        rti

COLORS
        ;     PBK  PF3  PF2  PF1  PF0  PM3  PM2  PM1  PM0
        ; PAL
        .byte $0E, $44, $0E, $00, $1C, $DA, $C8, $B4, $0E
        ; NTSC
        .byte      $54, $0E, $00, $2C, $EA, $D8, $C4, $0E

        ini     STARTUP
