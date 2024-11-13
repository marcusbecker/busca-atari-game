	processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Includes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "vcs.h"
	include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an uninitialized segment at $80 to $FF for variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg.u variables     ; Uninitialized segment
	org $80

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0xpos .byte 	        ; Player 0 X position 1 byte
P0ypos .byte 	        ; Player 0 Y position 1 byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PLAYER_HEIGHT = 10     ; Default size for player

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cartridge ROM from $F000 to $FFFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	seg code
    org $F000

Start:
	CLEAN_START      ; Macro to clean RAM and TIA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start game logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
	lda #2           ; Same as binary value %00000010
    sta VBLANK       ; Turn on VBLANK
    sta VSYNC        ; Turn on VSYNC

	REPEAT 3
		sta WSYNC
	REPEND

	lda #0
	sta VSYNC        ; Turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vertical Blank Time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REPEAT 37
		sta WSYNC    ; Let the TIA output the recommended 37 scanlines of VBLANK
	REPEND

    lda #0
	sta VBLANK		 ; Turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #$F8
    sta COLUPF               ; Set cave top color

	ldx #%11110000           ; Playerfield pattern
	stx PF0
	
	ldx #%11111111           ; Playerfield pattern
	stx PF1
	
	ldx #%11111111           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 1 - 6
    REPEND		
	
	ldx #%11100000           ; Playerfield pattern
	stx PF0
	
	ldx #%11011111           ; Playerfield pattern
	stx PF1
	
	ldx #%01111100           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 7 - 12
    REPEND	

	ldx #%11000000           ; Playerfield pattern
	stx PF0
	
	ldx #%10001110           ; Playerfield pattern
	stx PF1
	
	ldx #%00111000           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 13 - 18
    REPEND

	ldx #%10000000           ; Playerfield pattern
	stx PF0
	
	ldx #%00000100           ; Playerfield pattern
	stx PF1
	
	ldx #%00010000           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 19 - 24
    REPEND	

    lda #0                   ; 
    sta COLUPF               ; Disable playerfield

	REPEAT 6
        sta WSYNC            ; Cave top size
    REPEND

	;
	; Game init
	;

	REPEAT 132
        sta WSYNC            ;
    REPEND

	;
	; Game end
	;

    lda #$F2
    sta COLUPF               ; Set cave bottom color
	
	ldx #%10000000           ; Playerfield pattern
	stx PF0
	
	ldx #%00000100           ; Playerfield pattern
	stx PF1
	
	ldx #%00010000           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 1 - 6
    REPEND		
	
	ldx #%11000000           ; Playerfield pattern
	stx PF0
	
	ldx #%10001110           ; Playerfield pattern
	stx PF1
	
	ldx #%00111000           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 7 - 12
    REPEND	

	ldx #%11100000           ; Playerfield pattern
	stx PF0
	
	ldx #%11011111           ; Playerfield pattern
	stx PF1
	
	ldx #%01111100           ; Playerfield pattern
	stx PF2

	REPEAT 6
        sta WSYNC            ; Line 13 - 18
    REPEND

	ldx #%11110000           ; Playerfield pattern
	stx PF0
	
	ldx #%11111111           ; Playerfield pattern
	stx PF1
	
	ldx #%11111111           ; Playerfield pattern
	stx PF2	

	REPEAT 6
        sta WSYNC            ; Line 19 - 24
    REPEND	

    lda #0                   ; 
    sta COLUPF               ; Disable playerfield

	REPEAT 6
        sta WSYNC            ; Cave top size
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display VBLANK Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK               ; Turn on VBLANK again to display overscan
    REPEAT 30
        sta WSYNC            ; Display recommended lines of overscan
    REPEND
    lda #0
    sta VBLANK               ; Turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete the 4KB ROM size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start
