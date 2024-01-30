; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas & Urusergi
; "CPC Amsdos header" by CheshireCat/Flush
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

; calls link to : dzx0ah_elias dzx0ah_elias_loop dzx0ah_elias_backtrack

; in a header, the 32 first bytes are used by the Amsdos

        org #2000-#80 // #A7E4

        defs 32,0

dzx0_amsdosheader:
        ld      bc, $ffff               ; preserve default offset 1
        push    bc
        inc     bc
        ld      a, $80
dzx0ah_literals:
        call    dzx0ah_elias            ; obtain length
        ldir                            ; copy literals
        add     a, a                    ; copy from last offset or new offset?
        jr      c, dzx0ah_new_offset
        call    dzx0ah_elias            ; obtain length
dzx0ah_copy:
        ex      (sp), hl                ; preserve source, restore offset
        push    hl                      ; preserve offset
        add     hl, de                  ; calculate destination - offset
        ldir                            ; copy from offset
        pop     hl                      ; restore offset
        ex      (sp), hl                ; preserve offset, restore source
        add     a, a                    ; copy from literals or new offset?
        jr      nc, dzx0ah_literals
dzx0ah_new_offset:
        pop     bc                      ; discard last offset
        jr dzx0ah_new_offset_step       ; (small step for the header adaptation)
        defs 6,0
dzx0ah_new_offset_step:        
        ld      c, $fe                  ; prepare negative offset
        call    dzx0ah_elias_loop       ; obtain offset MSB
        inc     c
        ret     z                       ; check end marker
        ld      b, c
        ld      c, (hl)                 ; obtain offset LSB
        inc     hl
        rr      b                       ; last offset bit becomes first length bit
        rr      c
        push    bc                      ; preserve new offset
        ld      bc, 1                   ; obtain length
        call    nc, dzx0ah_elias_backtrack
        inc     bc
        jr      dzx0ah_copy
dzx0ah_elias:
        inc     c                       ; interlaced Elias gamma coding
dzx0ah_elias_loop:
        add     a, a
        jr      nz, dzx0ah_elias_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0ah_elias_skip:
        ret     c
dzx0ah_elias_backtrack:
        add     a, a
        rl      c
        rl      b
        jr      dzx0ah_elias_loop
; -----------------------------------------------------------------------------
; Twenty bytes left in the header after dzx0
