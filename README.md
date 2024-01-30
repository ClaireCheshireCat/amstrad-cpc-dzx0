# amstrad-cpc-dzx0
A ZX0 file decompressor you can use in BASIC on your Amstrad CPC.
The compressor could be found at https://github.com/einar-saukas/ZX0, or at my own fork https://github.com/ClaireCheshireCat/ZX0

dzx0.bin is a small (134 bytes) automatically relocatable executable file for use in Locomotive Basic.
It's a derivative work of Einar Saukas's & Urusergi ZX0 Z80 Standard decoder, https://github.com/einar-saukas
The Shinobi artwork present in the archive is from Eric Cubizolle, https://www.facebook.com/eric.titancubizolle

To use DZX0 on an Amstrad CPC, simply load it anywhere you want in the RAM, as long it's not a place which is used by the firmware
To decompress a file, simply do a :
CALL [Address of dzx0],[Address of the compressed data],[Address where to put the decompressed data]

Here is a minimal demo code :
```
10 MEMORY &3FFF
20 LOAD"DZX0.BIN",&4000
30 LOAD"SHINOBI.ZX0",&4086
40 CALL &4000,&4086,&C000
```

If you want to recompile or update dxz0, you will need SJASM+ : https://github.com/z00m128/sjasmplus
Otherwise the other includes needed are already in the archive.
