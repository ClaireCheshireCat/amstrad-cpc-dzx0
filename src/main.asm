;=======================================================
; Un petit dZX0 utilisable en BASIC !
;
;                               2024, Cheshirecat/Flush
;
; Ce décompresseur est relogeable, ce qui veut dire que
; vous pouvez le mettre n'importe où en mémoire, tant
; que vous n'écrasez pas des données du FW.
;
; Pour l'appeler à partir du Basic, il suffit de faire un :
;
; CALL [Adresse de la routine],[Adresse des données compressées],[Adresse de destination des données décompressées]
;
; Cas classique, si vous voulez décompresser un screen:
;
; 10 MEMORY &3FFF
; 20 LOAD"DZX0.BIN",&4000
; 30 LOAD"SHINOBI.ZX0",&4086
; 40 CALL &4000,&4086,&C000
;=======================================================

    include "src/std/dsk.asm"

    DEVICE AMSTRADCPC6128

    org #500
start:
    cp 2        ; On a besoin de lire deux paramètres, on compare donc le registre A à 2
    ret nz      ; Si reg A <> 2 on quitte

    ; Le code suivant permet de rendre le code relogeable.
    di
    call 15 ; Les quatre opcodes suivants permettent de faire l'équivalent d'un LD BC,PC
adressepc:  ; à l'adresse #15 il un a un #C9, qui correspond à un RET
    dec sp
    dec sp
    pop bc      ; BC est donc égal à adressepc !
    ei
;=============== on va patcher les adresses relog_dzx0s_elias1 et relog_dzx0s_elias1 avec la bonne adresse de dzx0s_elias
    ld hl,dzx0s_elias-adressepc
    add hl,bc
    ex hl,de    ; DE est maintenant égal à la véritable adresse du label dzx0s_elias
;--------------
    ld hl,relog_dzx0s_elias1-adressepc
    add hl,bc   ; HL est égal à la première adresse à patcher

    ld (hl),e
    inc hl
    ld (hl),d   ; Première adresse patchée !
;--------------
    ld hl,relog_dzx0s_elias2-adressepc
    add hl,bc   ; HL est égal à la première adresse à patcher

    ld (hl),e
    inc hl
    ld (hl),d   ; Seconde adresse patchée !

;=============== on va patcher l'adresse relog_dzx0s_elias_loop avec la bonne adresse de dzx0s_elias_loop
    ld hl,dzx0s_elias_loop-adressepc
    add hl,bc
    ex hl,de    ; DE est maintenant égal à la véritable adresse du label dzx0s_elias
;--------------
    ld hl,relog_dzx0s_elias_loop-adressepc
    add hl,bc   ; HL est égal à l'adresse à patcher

    ld (hl),e
    inc hl
    ld (hl),d   ; C'est patché !

;=============== on va patcher l'adresse relog_dzx0s_elias_backtrack avec la bonne adresse de dzx0s_elias_backtrack
    ld hl,dzx0s_elias_backtrack-adressepc
    add hl,bc
    ex hl,de    ; DE est maintenant égal à la véritable adresse du label dzx0s_elias
;--------------
    ld hl,relog_dzx0s_elias_backtrack-adressepc
    add hl,bc   ; HL est égal à l'adresse à patcher

    ld (hl),e
    inc hl
    ld (hl),d   ; On a fini !

;=============== Désormais le code de décompression est relogé. Reste à récupérer les paramètres
    ld e,(ix+0)
    ld d,(ix+1) ; DE = Adresse de destination des données décompressées
    ld l,(ix+2)
    ld h,(ix+3) ; HL = Adresse des données compressées
;=============== La routine de décompression suit, donc pas besoin de la CALLer. Et son RET rendra la main au Basic.

; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas & Urusergi
; "Standard" version (68 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

dzx0_standard:
        ld      bc, $ffff               ; preserve default offset 1
        push    bc
        inc     bc
        ld      a, $80
dzx0s_literals:
        call    dzx0s_elias             ; obtain length
relog_dzx0s_elias1 equ $-2
        ldir                            ; copy literals
        add     a, a                    ; copy from last offset or new offset?
        jr      c, dzx0s_new_offset
        call    dzx0s_elias             ; obtain length
relog_dzx0s_elias2 equ $-2
dzx0s_copy:
        ex      (sp), hl                ; preserve source, restore offset
        push    hl                      ; preserve offset
        add     hl, de                  ; calculate destination - offset
        ldir                            ; copy from offset
        pop     hl                      ; restore offset
        ex      (sp), hl                ; preserve offset, restore source
        add     a, a                    ; copy from literals or new offset?
        jr      nc, dzx0s_literals
dzx0s_new_offset:
        pop     bc                      ; discard last offset
        ld      c, $fe                  ; prepare negative offset
        call    dzx0s_elias_loop        ; obtain offset MSB
relog_dzx0s_elias_loop equ $-2
        inc     c
        ret     z                       ; check end marker
        ld      b, c
        ld      c, (hl)                 ; obtain offset LSB
        inc     hl
        rr      b                       ; last offset bit becomes first length bit
        rr      c
        push    bc                      ; preserve new offset
        ld      bc, 1                   ; obtain length
        call    nc, dzx0s_elias_backtrack
relog_dzx0s_elias_backtrack equ $-2
        inc     bc
        jr      dzx0s_copy
dzx0s_elias:
        inc     c                       ; interlaced Elias gamma coding
dzx0s_elias_loop:
        add     a, a
        jr      nz, dzx0s_elias_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0s_elias_skip:
        ret     c
dzx0s_elias_backtrack:
        add     a, a
        rl      c
        rl      b
        jr      dzx0s_elias_loop
; -----------------------------------------------------------------------------

    DISPLAY "Longueur de la routine : ",$-start

    LUA PASS3

        if(not dsk.create()) then
            sj.error("Can't create the DSK file")
        else
            if (not dsk.save("dzx0.bin",dsk.AMSDOS_FILETYPE_BINARY,sj.get_label("start"),sj.current_address,sj.get_label("start"))) then
                sj.error("Can't save the file")
            else
                if(not dsk.write("dist/dzx0.dsk")) then
                    sj.error("Can't save the DSK file")
                else
                    print("DSK saved.")
                end
            end
        end
    ENDLUA