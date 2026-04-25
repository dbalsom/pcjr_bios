# IBM PCjr BIOS Source Reconstruction

This is a reconstructed buildable source repo for the IBM PCjr BIOS. It produces a binary byte-for-byte identical with IBM's PCjr ROM.

The source started from OCR of IBM's published assembly listing, with a lot of manual cleanup.

## Notes

`pcjrbios.lst` is the transcription of the IBM PCjr BIOS source from the PCjr Technical Reference, Appendix A. It is a LST file produced by MASM, and cannot be assembled directly.

`pcjrbios.asm` is generated from the list file by `trim_asm.py`, which strips the listing columns to make an assembleable ASM file - if you want to customize the PCjr BIOS, this is probably what you want to edit. 

The published source did not include the Diagnostics ROM or ROM BASIC source. Those regions are included as opaque byte data in `DIAGROM.INC` and `BASICROM.INC`, extracted from the original ROM image.

IBM's original comments have been preserved wherever possible. Some small lowercase comments were added where the reconstruction needed an explanation.

## Build Instructions.

I've made a release ZIP containing the a patched IBM Macro Assembler 1.0 MASM.EXE and LINK.EXE from MASM 3.0. Download that and run `build.bat` in your favorite flavor of DosBox.

After you've built PCJRBIOS.EXE, you'll need to convert it to a BIN and calculate the checksum byte. Use the provided `exe2bin.py` which will do both for you.

```
py exe2bin.py pcjrbios.exe pcjrbios.bin --checksum
```

If you want to split the ROM into two 32K images for burning, you can add the `--split` argument.

## License

I make no license claim to IBM's original work, which remains (C)1983 IBM Corporation. 

The Python scripts are released into public domain via CC0.