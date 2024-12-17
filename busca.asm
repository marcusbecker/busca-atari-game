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
P0yoff .byte 	        ; Player 0 Y offset 1 byte
P0yPtr .byte 	        ; Player 0 Y pointer 1 byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PLAYER_HEIGHT = 9       ; Default size for player

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cartridge ROM from $F000 to $FFFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	seg code
    org $F000

Start:
	CLEAN_START      ; Macro to clean RAM and TIA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #70              ; Player 0 Y initial value (limit 143 to 10)
	sta P0ypos           ; Set player 0 Y initial value

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
    lda #$48                 ; player 0 color light red
    sta COLUP0

	lda #$F8
    sta COLUPF               ; Set cave top color

;;
;; Playerfield pattern TOP - 24 lines
;;
	ldy #0
LoopCaveTop:
	ldx CaveSprite,Y         ; Load Y line
	stx PF0                  ; Store col 1
	iny                      ; Increment Y
	
	ldx CaveSprite,Y         ; Load Y line
	stx PF1                  ; Store col 2
	iny                      ; Increment Y

	ldx CaveSprite,Y         ; Load Y line
	stx PF2                  ; Store col 3
	iny                      ; Increment Y	
	
	REPEAT 6
        sta WSYNC            ; Repeate for N vertical lines
    REPEND	

	cpy #12                  ; Compare with max lines
	bne LoopCaveTop          ; End loop

    lda #0                   ; 
    sta COLUPF               ; Disable playerfield

;;
;; Game  - 144 lines
;;

	lda #0
	sta P0yoff
	sta P0yPtr

	ldx #144
LoopGameLine:
	lda P0ypos
	sec
	sbc P0yPtr
	sta P0yoff
	
	txa
	sec
	sbc P0yoff
	bne EndGameLine

Player0Loop:
	ldy P0yPtr
    lda PlayerBitmap,Y
    sta GRP0
	
	cpy #PLAYER_HEIGHT
	beq EndGameLine
	inc P0yPtr

EndGameLine:
	sta WSYNC            ;
    lda #0
    sta GRP0             ; disable player 0 graphics
	dex
	bne LoopGameLine

;;
;; Playerfield pattern BOTTOM - 24 lines
;;
    lda #$F2
    sta COLUPF               ; Set cave bottom color

	ldy #12                  ; Load max lines plus one
LoopCaveBottom:
	dey                      ; Decrement Y
	ldx CaveSprite,Y         ; Load Y line
	stx PF2                  ; Store col 3
		
	dey                      ; Decrement Y
	ldx CaveSprite,Y         ; Load Y line
	stx PF1                  ; Store col 2
	
	dey                      ; Decrement Y
	ldx CaveSprite,Y         ; Load Y line
	stx PF0                  ; Store col 1
	
	REPEAT 6
        sta WSYNC            ; Repeate for N vertical lines
    REPEND	

	cpy #0                   ; Compare with 0
	bne LoopCaveBottom       ; End loop

	lda #0                   ; 
    sta COLUPF               ; Disable playerfield

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
;; Check joystick input for player 0 up/down/left/right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000           ; joystick up for player 0
    bit SWCHA
    bne ExitCheckP0
    lda P0ypos
    cmp #140                 ; if (player0 Y position > 70)
    bpl ExitCheckP0          ;    then: skip increment
.P0UpPressed:                ;    else:
    inc P0ypos               ;        increment Y position

ExitCheckP0:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Playerfield pattern
CaveSprite:
	.byte #%11110000           ; Line-Col 1-1
	.byte #%11111111           ; Line-Col 1-2
	.byte #%11111111           ; Line-Col 1-3
	.byte #%11100000           ; Line-Col 2-1
	.byte #%11011111           ; Line-Col 2-2
	.byte #%01111100           ; Line-Col 2-3
	.byte #%11000000           ; Line-Col 3-1
	.byte #%10001110           ; Line-Col 3-2
	.byte #%00111000           ; Line-Col 3-3
	.byte #%10000000           ; Line-Col 4-1
	.byte #%00000100           ; Line-Col 4-2
	.byte #%00010000           ; Line-Col 4-3

PlayerBitmap:
    .byte #%11000000           ; ##
	.byte #%11000000           ; ##
    .byte #%01100000           ;  ## 
	.byte #%01100000           ;  ##
    .byte #%11110000           ; ####
	.byte #%11110000           ; ####
    .byte #%01100000           ;  ##
	.byte #%01100000           ;  ##
    .byte #%11000000           ; ## 
	.byte #%11000000           ; ## 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete the 4KB ROM size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start
