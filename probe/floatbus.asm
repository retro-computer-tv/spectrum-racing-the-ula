; The floating bus, seen in the border. A band of character rows (8 to 15) gets an attribute used nowhere else
; (9: blue ink on blue paper). The loop reads an unattached port again and again: whenever the byte that comes
; back is 9, the ULA was fetching that band's colours at that moment, and the border turns blue; otherwise white.
; On a 48K, blue marks appear in the border beside the band and nowhere else. On a +2A or +3, whose gate array
; keeps the ULA's bus apart from the processor's, port $FF reads 255 every time and the border stays white.
    DEVICE ZXSPECTRUM48
    ORG $8000
start:
    di
    ld sp,$fe00
    ld hl,$5800             ; every attribute white paper, black ink
    ld de,$5801
    ld bc,767
    ld (hl),$38
    ldir
    ld hl,$5800+8*32        ; rows 8 to 15: attribute 9
    ld de,$5800+8*32+1
    ld bc,8*32-1
    ld (hl),9
    ldir
loop:
    ld a,$00                ; port $00FF: high byte outside contended memory
    in a,($ff)
    cp 9
    ld a,7                  ; white
    jr nz,show
    ld a,1                  ; blue
show:
    out ($fe),a
    jr loop
code_end:

; A tape that runs on every model: 10 CLEAR 32767: LOAD ""CODE: RANDOMIZE USR 32768
basic:
    db 0,10
    dw line10_end - line10
line10:
    db $FD, '32767', $0E, 0,0, $FF,$7F, 0, ':', $EF, '""', $AF, ':', $F9, $C0, '32768', $0E, 0,0, $00,$80, 0, $0D
line10_end:
basic_end:
    EMPTYTAP "floatbus.tap"
    SAVETAP "floatbus.tap", BASIC, "floatbus", basic, basic_end-basic, 10
    SAVETAP "floatbus.tap", CODE, "probe", start, code_end-start, start
