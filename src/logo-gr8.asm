save_a          = $F7
save_x          = $F8
save_y          = $F9
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

HPOSP0          = $D000                        ; player 0 horizontal position
HPOSP1          = $D001                        ; player 1 horizontal position
HPOSP2          = $D002                        ; player 2 horizontal position
HPOSP3          = $D003                        ; player 3 horizontal position
HPOSM0          = $D004                        ; missile 0 horizontal position
HPOSM1          = $D005                        ; missile 1 horizontal position
HPOSM2          = $D006                        ; missile 2 horizontal position
HPOSM3          = $D007                        ; missile 3 horizontal position
SIZEP0          = $D008                        ; player 0 size
SIZEP1          = $D009                        ; player 1 size
SIZEP2          = $D00A                        ; player 2 size
SIZEP3          = $D00B                        ; player 3 size
SIZEM           = $D00C                        ; missile sizes
TRIG0           = $D010                        ; joystick trigger 0
TRIG1           = $D011                        ; joystick trigger 1
COLPM0          = $D012                        ; player-missile 0 color/luminance
COLPM1          = $D013                        ; player-missile 1 color/luminance
COLPM2          = $D014                        ; player-missile 2 color/luminance
COLPM3          = $D015                        ; player-missile 3 color/luminance
COLPF0          = $D016                        ; playfield 0 color/luminance
COLPF1          = $D017                        ; playfield 1 color/luminance
COLPF2          = $D018                        ; playfield 2 color/luminance
COLPF3          = $D019                        ; playfield 3 color/luminance
COLBK           = $D01A                        ; background color/luminance
PRIOR           = $D01B                        ; priority select
VDELAY          = $D01C                        ; vertical delay
GRACTL          = $D01D                        ; graphic control
HITCLR          = $D01E                        ; collision clear
CONSOL          = $D01F                        ; console switches and speaker control
PORTA           = $D300                        ; port A direction register or jacks one/two
PORTB           = $D301                        ; port B direction register or memory management
PACTL           = $D302                        ; port A control
PBCTL           = $D303                        ; port B control
DMACTL          = $D400                        ; DMA control
CHACTL          = $D401                        ; character control
DLISTL          = $D402                        ; low display list address
DLISTH          = $D403                        ; high display list address
HSCROL          = $D404                        ; horizontal scroll
VSCROL          = $D405                        ; vertical scroll
PMBASE          = $D407                        ; player-missile base address
CHBASE          = $D409                        ; character base address
WSYNC           = $D40A                        ; wait for HBLANK synchronization
NMIEN           = $D40E                        ; NMI enable
NMIRES          = $D40F                        ; NMI interrupt reset


        org     $2000

DLIST   .byte   $70,$70,$70,$70,$60,$4F
        .word   SCREEN
        :60 .byte 15
        .byte   $50
        :11 .byte 15
        .byte   $D0
        .byte   15, 15
        :29     dta $4F, a(REPLINE), $0F
        dta $4F, a(REPLINE)
        .byte   $41
        .word   DLIST

SCREEN
        ins     'scr8.bin',+1248,1952
        ins     'scr8.bin',+3392,352
REPLINE
        ins     'scr8.bin',+3936,64


DLI     sta     save_a
        stx     save_x
        sty     save_y
        lda     #$81
        ldx     #$46
        ldy     #$72
        sta     WSYNC
        sta     PRIOR
        lda     #$3A
        sta     COLPF1
        stx     COLPF2
        sty     COLBK
        lda     save_a
        ldx     save_x
        ldy     save_y
        rti

STARTUP lda     RTCLOK
L2C02   cmp     RTCLOK
        beq     L2C02
        sei
        lda     #$00
        sta     NMIEN
        sta     DMACTL

        mwa     #DLI    VDSLST
        mwa     #DLIST  SDLSTL

        ldx     #8
SCLR    lda     COLORS, x
        sta     PCOLR0, x
        dex
        bpl     SCLR

        lda     #$01
        sta     GPRIOR
        lda     #$01
        sta     VSCROL
        lda     #$3D
        sta     SDMCTL

        lda     #$C0
        sta     NMIEN
        cli

L2C28   lda     TRIG0
        beq     L2C40
        lda     TRIG1
        beq     L2C40
        lda     CONSOL
        and     #$01
        beq     L2C40
        lda     $D20F
        and     #$04
        bne     L2C28
L2C40   lda     #$00
        sta     GRACTL
        tax
L2C46   sta     HPOSP0,x
        inx
        bne     L2C46
        lda     #$40
        sta     NMIEN
        rts

COLORS
        ;     PM0  PM1  PM2  PM3  PF0  PF1  PF2  PF3  PBK
        .byte $0E, $C4, $D8, $EA, $2C, $00, $0E, $54, $0E

        ini     STARTUP
