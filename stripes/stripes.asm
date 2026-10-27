; Stripes in the border. The border has no picture stored anywhere: the ULA draws whatever border colour is set at
; the moment its beam passes. So a program that changes the colour at fixed times after the frame interrupt draws
; stripes, and where each colour edge lands shows exactly when each OUT happened.
;
; After each interrupt: 28 changes between blue and red, a fixed delay apart. Each edge lands on an 8-pixel step
; of the border (the border colour is taken up every 4 T-states). On a Spectrum that draws its picture one T-state
; later, these edges land a whole step earlier: a one T-state shift moves an edge only when it tips it across a
; step, as it does for these.
;
; Assemble with sjasmplus: sjasmplus stripes.asm   (writes stripes.tap: LOAD "" runs it)
    DEVICE ZXSPECTRUM48
    ORG $8000
start:
    ld sp,$fe00
    ei
frame:
    halt                    ; wait for the frame interrupt
    ld a,1                  ; blue
    ld c,28
loop:
    out ($fe),a             ; the border colour, from this moment
    xor 3                   ; blue (1) <-> red (2)
    ld b,135
w:  djnz w
    dec c
    jr nz,loop
    jr frame
code_end:

; 10 CLEAR 32767: LOAD ""CODE: RANDOMIZE USR 32768
basic:
    db 0,10
    dw line10_end - line10
line10:
    db $FD, '32767', $0E, 0,0, $FF,$7F, 0, ':', $EF, '""', $AF, ':', $F9, $C0, '32768', $0E, 0,0, $00,$80, 0, $0D
line10_end:
basic_end:
    EMPTYTAP "stripes.tap"
    SAVETAP "stripes.tap", BASIC, "stripes", basic, basic_end-basic, 10
    SAVETAP "stripes.tap", CODE, "stripes", start, code_end-start, start
