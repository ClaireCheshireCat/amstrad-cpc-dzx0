    ifndef INCLUDE_DSK_ASM
    define INCLUDE_DSK_ASM

    display "DSK - Amstrad CPC DSK management by CheshireCat/Flush"

    ; Wrapper for the DSK functions
    LUA
        package.path = "./src/std/?.lua;"..package.path
        dsk = require("dsk")
    ENDLUA

    endif