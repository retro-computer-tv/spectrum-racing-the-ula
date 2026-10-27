# Racing the ULA: the programs

The small ZX Spectrum programs from Retro Computer TV's film *Racing the ULA: How Programmers Broke the ZX Spectrum's Rules*. Each one races the Spectrum's ULA, the chip that draws the picture, and shows the result on screen.

| Folder | What it shows | Machine |
|---|---|---|
| [stripes](stripes/stripes.asm) | Stripes drawn in the border by changing its colour at fixed times after the frame interrupt. Each edge lands on an 8-pixel step. | 48K |
| [probe](probe/floatbus.asm) | The floating bus: reading a port nothing answers returns the byte the ULA is fetching. The border shows blue beside one band of the screen, and nowhere else. On a +2A or +3 it stays white. | 48K; +2A or +3 for the contrast |
| [band](band/band.asm) | Multicolour: one character row rewritten once per pixel line, so each line gets its own colour. It holds up to 16 columns on a 48K and breaks into steps at 17. | 48K |

## Building

Each file assembles with [sjasmplus](https://github.com/z00m128/sjasmplus) (1.24.0 or later):

```sh
sjasmplus stripes.asm                                  # stripes.tap
sjasmplus floatbus.asm                                 # floatbus.tap
sjasmplus -DCOLS=16 -DSTART=228 -DPAD=0 band.asm       # band.sna
```

The tapes load with `LOAD ""`. The band builds a snapshot; its header lists the settings for each width. Run them on a real Spectrum or in an emulator with accurate timing. You need your own copy of the Spectrum ROM for an emulator.

## Licence

MIT, see [LICENSE](LICENSE).
