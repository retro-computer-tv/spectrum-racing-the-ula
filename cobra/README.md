# Cobra on a +2A or +3: a one-POKE fix

Cobra (Ocean, 1986) freezes on its first frame of play on a Spectrum +2A or +3. One POKE stops the freeze:

```
POKE 38405,16
```

Put it in once the game has loaded, at the menu. It also works after the game has frozen: the game carries on at once.

## Why it freezes

[Racing the ULA](https://www.youtube.com/watch?v=dgmdkphy2as&t=417) shows the cause. Before drawing each picture, Cobra waits for the ULA in a four-instruction loop at 38401 to 38406. The loop reads port $28FF until a screen byte below 63 comes back, the floating-bus trick. On a 48K the ULA's bytes leak into that read. On a +2A or +3 the port always reads 255, and interrupts are off, so the loop never ends.

Address 38405 holds the loop's `JR NC` (48). `POKE 38405,16` makes it `DJNZ`, with the same jump. The loop then runs 63 times, about 2,000 T-states, and returns whatever the port says. Like The Hit Squad's 1989 re-release, which rewrote the same ten bytes as a countdown, it waits a fixed time instead of watching the beam. So the picture can flicker a little, as it does in that release.

## How to put it in

- **In an emulator:** copy [Cobra.pok](Cobra.pok) beside your tape file and give it the same name (`Cobra.tzx` and `Cobra.pok`). Fuse finds it when the tape loads. Once the menu is up, open Machine, Poke Memory and tick the fix. Or type address 38405 and value 16 into that dialog yourself. Other emulators that read .pok files can load it too.
- **On a real +2A or +3 with a Multiface 3:** press its button at the menu, POKE 38405,16 and return to the game.

POKEd before the game has loaded, it does nothing: the loader writes the routine at the end of loading, over anything put there earlier.

You need your own copy of Cobra. Nothing of the game is in this repository. The Hit Squad's re-release already has its own fix.

## Tested

In Fuse 1.10 emulating a +3, with the original Ocean tape: unpatched, the game freezes on its first frame of play. With the POKE, it plays through to game over and returns to the menu, at the same pace as with the Hit Squad's ten bytes. We haven't tried it on a real +3. The fix doesn't depend on what the port returns, so the emulator's handling of the port doesn't affect it.

## Thanks

To simonebernacchia5724, who asked [under the video](https://www.youtube.com/watch?v=dgmdkphy2as&lc=Ugw4JS03iNbvTsTmM1R4AaABAg) whether Cobra could be patched.
