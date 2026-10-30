# Racing the ULA: the programs

The small ZX Spectrum programs from Retro Computer TV's film *Racing the ULA: How Programmers Broke the ZX Spectrum's Rules*. Each one races the Spectrum's ULA, the chip that draws the picture, and shows the result on screen.

| Program | What it shows | Machine |
|---|---|---|
| [stripes](stripes/stripes.asm) | Stripes drawn in the border by changing its colour at fixed times after the frame interrupt. Each edge lands on an 8-pixel step. | 48K |
| [floatbus](probe/floatbus.asm) | The floating bus: reading a port nothing answers returns the byte the ULA is fetching. The border shows blue beside one band of the screen, and nowhere else. On a +2A or +3 it stays white. | 48K; +2A or +3 for the contrast |
| [band](band/band.asm) | Multicolour: one character row rewritten once per pixel line, so each line gets its own colour. It holds up to 16 columns on a 48K and breaks into steps at 17. | 48K |
| [cobra](cobra/README.md) | A one-POKE fix for Cobra (Ocean, 1986), which freezes on a +2A or +3 because it waits on the floating bus. | +2A or +3 |

## Run them

Nothing to build: everything ready to run is in the [run](run) folder. Pick whichever suits your machine.

| Program | Tape file | Tape sound | Type it in |
|---|---|---|---|
| stripes | [stripes.tap](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/stripes.tap) | [stripes.wav](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/stripes.wav) | [stripes.bas.txt](run/stripes.bas.txt) |
| floatbus | [floatbus.tap](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/floatbus.tap) | [floatbus.wav](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/floatbus.wav) | [floatbus.bas.txt](run/floatbus.bas.txt) |
| band, 16 columns (whole) | [band-16.tap](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/band-16.tap) | [band-16.wav](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/band-16.wav) | |
| band, 17 columns (breaks) | [band-17.tap](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/band-17.tap) | [band-17.wav](https://github.com/retro-computer-tv/spectrum-racing-the-ula/raw/main/run/band-17.wav) | |

**In an emulator.** Open the `.tap` file in [Fuse](https://fuse-emulator.sourceforge.net/) or any Spectrum emulator with accurate timing, set to a 48K. It loads and starts by itself (if not, type `LOAD ""`). Fuse comes with the Spectrum's ROM.

**On a real Spectrum, from the sound file.** Connect a phone or PC's headphone socket to the Spectrum's EAR socket, type `LOAD ""` and play the `.wav` at high volume, as you would a cassette. It takes about 20 seconds. A tape or SD interface (a TZXDuino, a divMMC and so on) takes the `.tap` file instead.

**Typed in.** stripes and floatbus are short enough to type into BASIC. Type the listing in and `RUN` it: it POKEs the program into memory and starts it. Each `DATA` line holds eight bytes and then their sum, so a mistyped number stops it with `Check line` and the line to look at. The listings:

stripes:

```
10 CLEAR 32767: LET a=32768
20 FOR l=100 TO 120 STEP 10
30 LET s=0: FOR i=1 TO 8: READ b: POKE a,b: LET a=a+1: LET s=s+b: NEXT i
40 READ c: IF s<>c THEN PRINT "Check line ";l: STOP
50 NEXT l
60 RANDOMIZE USR 32768
100 DATA 49,0,254,251,118,62,1,14,749
110 DATA 28,211,254,238,3,6,135,16,891
120 DATA 254,13,32,245,24,238,0,0,806
```

floatbus:

```
10 CLEAR 32767: LET a=32768
20 FOR l=100 TO 150 STEP 10
30 LET s=0: FOR i=1 TO 8: READ b: POKE a,b: LET a=a+1: LET s=s+b: NEXT i
40 READ c: IF s<>c THEN PRINT "Check line ";l: STOP
50 NEXT l
60 RANDOMIZE USR 32768
100 DATA 243,49,0,254,33,0,88,17,684
110 DATA 1,88,1,255,2,54,56,237,694
120 DATA 176,33,0,89,17,1,89,1,406
130 DATA 255,0,54,9,237,176,62,0,793
140 DATA 219,255,254,9,62,7,32,2,840
150 DATA 62,1,211,254,24,240,0,0,792
```

The last line of each ends in 0s that only fill it out. The band is 528 bytes, too long to type in comfortably.

The programs run until the machine is reset. They were tuned and tested in Fuse 1.10.0 on a 48K. Real 48Ks differ slightly in timing: if the band's edge shimmers, rebuild it with `START` a few T-states either way (the settings are in [band.asm](band/band.asm)).

## Building

To change a program and build it again, you need [sjasmplus](https://github.com/z00m128/sjasmplus) 1.24.0 or later. On Windows, take the ready-made `.exe` from its [releases page](https://github.com/z00m128/sjasmplus/releases) (the zip with `win` in its name), not the source code. With Python 3:

```sh
python build.py              # everything, into run/ (SJASMPLUS=/path/to/sjasmplus if it isn't on the PATH)
```

Or one program by hand, from its folder:

```sh
sjasmplus stripes.asm                                  # stripes.tap
sjasmplus floatbus.asm                                 # floatbus.tap
sjasmplus -DCOLS=16 -DSTART=228 -DPAD=0 band.asm       # band.tap; its header lists the settings for each width
```

The `.wav` files are made from the `.tap` files by `tape2wav`, from [fuse-utils](https://fuse-emulator.sourceforge.net/).

## Licence

MIT, see [LICENSE](LICENSE).
