; A colour on every pixel line of one character row, on a 48K ZX Spectrum.
;
; The ULA reads each 8x8 cell's colour byte (its attribute) again for every one of the cell's 8 pixel lines. So if
; a program rewrites a row's attributes once per line, just after the ULA has read them, each pixel line gets a
; colour of its own. This program does that for character row 8 (pixel lines 64 to 71), one LD (HL),A / INC L per
; cell, as fast as the Z80 can write, then waits out the rest of the 224 T-state line.
;
; COLS sets how many cells across are rewritten. On a 48K the band holds up to 16 columns, where a line's work takes
; exactly the 224 T-states of the line. At 17 it takes longer than the line, so each line starts later than the one
; before, the last cells still hold the colour from the line before, and the band breaks into steps.
;
; START (T-states after the frame interrupt, past a fixed base) and PAD (T-states of padding at the end of each
; line) were tuned for each width in Fuse 1.10.0, 48K, so that every line of the band comes out whole and in a colour
; of its own:
;
;   COLS   START   PAD
;     1     228    193
;     4     228    152
;     8     228    100
;    12     228     49
;    16     228      0
;    17     228      0    (it can't be whole: this is the failure)
;
; Assemble with sjasmplus: sjasmplus -DCOLS=16 -DSTART=228 -DPAD=0 band.asm   (writes band.sna)
; Real 48Ks differ slightly in timing; if the band's edge shimmers, try START a few T-states either way.

    DEVICE ZXSPECTRUM48
    IFNDEF COLS
COLS = 16
    ENDIF
    IFNDEF START
START = 228
    ENDIF
    IFNDEF PAD
PAD = 0
    ENDIF
ATTR = $5800 + 8*32

; exactly t T-states of instructions that change nothing that matters: LD C,0 (7) and NOP (4)
    MACRO PADDING t
    IF (t) % 4 == 0
        DUP (t) / 4
        nop
        EDUP
    ELSE
    IF (t) >= 7 && ((t) - 7) % 4 == 0
        ld c,0
        DUP ((t) - 7) / 4
        nop
        EDUP
    ELSE
    IF (t) >= 14 && ((t) - 14) % 4 == 0
        ld c,0
        ld c,0
        DUP ((t) - 14) / 4
        nop
        EDUP
    ELSE
        ld c,0
        ld c,0
        ld c,0
        DUP ((t) - 21) / 4
        nop
        EDUP
    ENDIF
    ENDIF
    ENDIF
    ENDM

    ORG $8000
start:
    di
    ld sp,$7ff0
    xor a
    out ($fe),a             ; black border
    ld hl,$4000             ; clear the bitmap, so each cell shows only its paper colour
    ld de,$4001
    ld bc,6143
    ld (hl),l
    ldir
    ld hl,$5800             ; every attribute: black paper
    ld de,$5801
    ld bc,767
    ld (hl),0
    ldir
    ld hl,$fe00             ; interrupt mode 2, so the frame interrupt runs isr: a table of $fd bytes
    ld de,$fe01             ; sends it to $fdfd, which jumps to isr
    ld bc,256
    ld (hl),$fd
    ldir
    ld a,$c3
    ld ($fdfd),a
    ld hl,isr
    ld ($fdfe),hl
    ld a,$fe
    ld i,a
    im 2
    ei
idle:
    jr idle

; Once a frame: wait for the beam to reach the band, then rewrite the row's colours for each of its 8 lines.
isr:
    ld a,(phase)            ; animate: start one colour further along each frame
    inc a
    and 7
    ld (phase),a
    ld de,colours
    add a,e
    ld e,a
    ld bc,1080 + START / 26
wait:
    dec bc
    ld a,b
    or c
    jr nz,wait
    PADDING START % 26 + 20
    DUP 8
    ld a,(de)               ; this line's colour
    inc e
    ld hl,ATTR
    DUP COLS
    ld (hl),a
    inc l
    EDUP
    PADDING PAD
    EDUP
    ei
    reti
phase:
    db 0
    ALIGN 256
colours:                    ; paper colours as attributes (paper << 3), twice round
    db 1<<3, 2<<3, 6<<3, 4<<3, 5<<3, 3<<3, 7<<3, 2<<3
    db 1<<3, 2<<3, 6<<3, 4<<3, 5<<3, 3<<3, 7<<3, 2<<3
    SAVESNA "band.sna", start
