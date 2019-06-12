; Uses the 40x48d page1/page2 every-1-scanline pageflip mode

; self modifying code to get some extra colors (pseudo 40x192 mode)

; by deater (Vince Weaver) <vince@deater.net>

; Zero Page
FRAMEBUFFER	= $00	; $00 - $0F
CH		= $24
CV		= $25
GBASL		= $26
GBASH		= $27
BASL		= $28
BASH		= $29
FRAME		= $60
BLARGH		= $69
DRAW_PAGE	= $EE
LASTKEY		= $F1
PADDLE_STATUS	= $F2
YPOS		= $F3
YADD		= $F4
BLAST1		= $F5
BLAST2		= $F6
FIRE		= $F7
TEMP		= $FA
WHICH		= $FB
TEMPY		= $FC
LEVEL_DONE	= $FD
OUTL		= $FE
OUTH		= $FF

ZERO		= $80


; Soft Switches
KEYPRESS= $C000
KEYRESET= $C010
SET_GR	= $C050 ; Enable graphics
FULLGR	= $C052	; Full screen, no text
PAGE0	= $C054 ; Page0
PAGE1	= $C055 ; Page1
LORES	= $C056	; Enable LORES graphics
PADDLE_BUTTON0 = $C061
PADDL0	= $C064
PTRIG	= $C070

; ROM routines

TEXT	= $FB36				;; Set text mode
HOME	= $FC58				;; Clear the text screen
WAIT	= $FCA8				;; delay 1/2(26+27A+5A^2) us


start_sprites:

	;===================
	; init screen
	jsr	TEXT
	jsr	HOME
	bit	KEYRESET

	;===================
	; init vars

	lda	#0
	sta	DRAW_PAGE
	sta	WHICH
	sta	ZERO
	sta	YADD
	sta	LEVEL_DONE

	lda	#64
	sta	YPOS

	;=============================
	; Load graphic page0

	lda	#$0c
	sta	BASH
	lda	#$00
	sta	BASL                    ; load image to $c00

	lda	WHICH
	asl
	asl				; which*4
	tay

	lda	pictures,Y
	sta	GBASL
	lda	pictures+1,Y
	sta	GBASH
	jsr	load_rle_gr

	lda	#4
	sta	DRAW_PAGE

	jsr	gr_copy_to_current	; copy to page1

	; GR part
	bit	PAGE1
	bit	LORES							; 4
	bit	SET_GR							; 4
	bit	FULLGR							; 4

;	jsr	wait_until_keypressed


	;=============================
	; Load graphic page1

	lda	#$0c
	sta	BASH
	lda	#$00
	sta	BASL                    ; load image to $c00

	lda	WHICH
	asl
	asl				; which*4
	tay

	lda	pictures+2,Y
	sta	GBASL
	lda	pictures+3,Y
	sta	GBASH
	jsr	load_rle_gr

	lda	#0
	sta	DRAW_PAGE

	jsr	gr_copy_to_current

;	; GR part
	bit	PAGE0

;	jsr	wait_until_keypressed


	;==============================
	; setup graphics for vapor lock
	;==============================

	jsr	vapor_lock

	; vapor lock returns with us at beginning of hsync in line
	; 114 (7410 cycles), so with 5070 lines to go

	; GR part
	bit	LORES							; 4
	bit	SET_GR							; 4
	bit	FULLGR							; 4

	jsr	gr_copy_to_current			; 6+ 9292

	; 5070 + 4550 = 9620
	;		9292
	;		  12
	;		   6
	;		====
	;		 310

	; - 3 for jmp
	; 307

	; Try X=9 Y=6 cycles=307

	ldy	#6							; 2
loopA:	ldx	#9							; 2
loopB:	dex								; 2
	bne	loopB							; 2nt/3
	dey								; 2
	bne	loopA							; 2nt/3

	jmp	display_loop						; 3

.align  $100

	;================================================
	; Display Loop
	;================================================
	; each scan line 65 cycles
	;       1 cycle each byte (40cycles) + 25 for horizontal
	;       Total of 12480 cycles to draw screen
	; Vertical blank = 4550 cycles (70 scan lines)
	; Total of 17030 cycles to get back to where was

	; We want to alternate between page1 and page2 every 65 cycles
        ;       vblank = 4550 cycles to do scrolling


display_loop:

.include "sprites_screen.s"

	;======================================================
	; We have 4550 cycles in the vblank, use them wisely
	;======================================================

	; 4550	-- VBLANK
	; 1821	-- draw ship (130*14)+1
	;  -31	-- move ship
	;  -61  -- keypress
	;   -8  -- loop
	;=======
	; 2629

	;==========================
	; move the ship
	; in bounds:	14+5 =    19 [12]
	; too small:	14+10 =   24 [7]
	; too big:	14+5+12 = 31

	clc				; 2
	lda	YPOS			; 3
	adc	YADD			; 3
	sta	YPOS			; 3
	bpl	not_minus		; 3

minus:
					; -1
	lda	#$0			; 2
	sta	YPOS			; 3
	sta	YADD			; 3
	jmp	done_move_delay_7	; 3
not_minus:
	cmp	#111			; 2
	bcc	done_move_delay_12	; blt	; 3
					; -1
	lda	#$0			; 2
	sta	YADD			; 3
	lda	#110			; 2
	sta	YPOS			; 3
	jmp	done_move		; 3
done_move_delay_12:
	lda	TEMP			; 3
	nop				; 2
done_move_delay_7:
	lda	TEMP			; 3
	nop				; 2
	nop				; 2

done_move:




	;==========================
	; draw the ship
	; at Y=64 for now

	ldy	YPOS			; 3

	; line 0
	ldx	#0			; 2
	jsr	sprite_line		; 6+120
					;====
					; 128

	; line 1
	iny				; 2
	ldx	#7			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 2
	iny				; 2
	ldx	#14			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 3
	iny				; 2
	ldx	#21			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 4
	iny				; 2
	ldx	#28			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 5
	iny				; 2
	ldx	#35			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 6
	iny				; 2
	ldx	#42			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 7
	iny				; 2
	ldx	#49			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 8
	iny				; 2
	ldx	#56			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 9
	iny				; 2
	ldx	#63			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 10
	iny				; 2
	ldx	#70			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 11
	iny				; 2
	ldx	#77			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 12
	iny				; 2
	ldx	#84			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130

	; line 13
	iny				; 2
	ldx	#91			; 2
	jsr	sprite_line		; 6+120
					;====
					; 130



pad_time:


	;============================
	; WAIT for VBLANK to finish
	;============================

	; Try X=6 Y=73 cycles=2629

	ldy	#73							; 2
loop1:	ldx	#6							; 2
loop2:	dex								; 2
	bne	loop2							; 2nt/3
	dey								; 2
	bne	loop1							; 2nt/3

	jsr	handle_keypress					; 6+55

	;===============
	; check for end

	lda	LEVEL_DONE					; 3
	bne	done_level					; 2
	jmp	display_loop					; 3

done_level:
	rts

.align	$100
	;=======================
	; handle keypress
	;=======================
	; separate function so we an align to avoid branches
	; crossing page boundaries
	;
	; NONE = 6+7			= 13	[42]
	; ESC  = doesn't matter
	; ' '  = 6+6+9+5+7		= 33	[22] [[20]]
	; '.'  = 6+6+9+5+5+7		= 48	[17] [[5]]
	; ','  = 6+6+9+5+5+5+7		= 43	[12] [[5]]
	; 'A'  = 6+6+9+5+5+5+7+7	= 50	[5]  [[7]]
	; 'Z'  = 6+6+9+5+5+5+7+5+7	= 55	[0]  [[5]]
	; unkno= 6+6+9+5+5+5+7+5+3+[4]	= 55	[0]
handle_keypress:
	lda	KEYPRESS				; 4
	bpl	key_delay_42				; 3
							; -1

	bit	KEYRESET	; clear strobe		; 4

	cmp	#27+$80					; 2
	bne	key_not_escape				; 3

	lda	#1
	sta	LEVEL_DONE

	rts

key_not_escape:

	cmp	#' '+$80				; 2
	bne	key_not_space				; 3
							; -1
	lda	#1					; 2
	sta	FIRE					; 3
	jmp	key_delay_22				; 3

key_not_space:
	cmp	#'.'+$80				; 2
	bne	key_not_period				; 3
							; -1
	lda	#1					; 2
	sta	BLAST1					; 3
	jmp	key_delay_17				; 3

key_not_period:
	cmp	#','+$80				; 2
	bne	key_not_comma				; 3
							; -1
	lda	#1					; 2
	sta	BLAST2					; 3
	jmp	key_delay_12				; 3

key_not_comma:
	and	#$5f	; make uppercase		; 2

	cmp	#'A'					; 2
	bne	key_not_a				; 3
							; -1
	dec	YADD					; 5
	jmp	key_delay_5				; 3

key_not_a:
	cmp	#'Z'					; 2
	bne	key_not_z				; 3
							; -1
	inc	YADD					; 5
	jmp	keypress_done				; 3

key_not_z:
	nop						; 2
	nop						; 2
	jmp	keypress_done				; 3

key_delay_42:
	inc	TEMP					; 5
	dec	TEMP					; 5
	inc	TEMP					; 5
	dec	TEMP					; 5

key_delay_22:
	nop						; 2
	lda	TEMP					; 3
key_delay_17:
	nop						; 2
	lda	TEMP					; 3
key_delay_12:
	nop						; 2
	nop						; 2
	lda	TEMP					; 3

key_delay_5:
	nop						; 2
	lda	TEMP					; 3

keypress_done:
	rts						; 6


	;========================
	; Draw a line of a sprite
	;========================
	; Y = y value
	; x = location in sprite
	; 17+10+(7*12)+3+6 = 120
sprite_line:
	sty	TEMPY			; 3

	lda	y_lookup_l,Y		; 4
	sta	OUTL			; 3
	lda	y_lookup_h,Y		; 4
	sta	OUTH			; 3
					;=======
					; 17

	; XPOS
	lda	#1	; xpos=1	; 2
	ldy	#0			; 2
	sta	(OUTL),Y		; 6
					;=======
					; 10
	; COL0
	ldy	#2			; 2
	lda	ship_sprite+0,X		; 4
	sta	(OUTL),Y		; 6
					;=======
					; 12
	; COL1
	ldy	#7			; 2
	lda	ship_sprite+1,X		; 4
	sta	(OUTL),Y		; 6

	; COL2
	ldy	#12			; 2
	lda	ship_sprite+2,X		; 4
	sta	(OUTL),Y		; 6

	; COL3
	ldy	#17			; 2
	lda	ship_sprite+3,X		; 4
	sta	(OUTL),Y		; 6

	; COL4
	ldy	#22			; 2
	lda	ship_sprite+4,X		; 4
	sta	(OUTL),Y		; 6

	; COL5
	ldy	#27			; 2
	lda	ship_sprite+5,X		; 4
	sta	(OUTL),Y		; 6

	; COL6
	ldy	#32			; 2
	lda	ship_sprite+6,X		; 4
	sta	(OUTL),Y		; 6

	ldy	TEMPY			; 3
	rts				; 6


.include "gr_simple_clear.s"
.include "gr_offsets.s"


.include "../asm_routines/gr_unrle.s"
.include "../asm_routines/keypress.s"
.align $100
.include "sprites_table.s"
.include "movement_table.s"
.include "gr_copy.s"
.include "vapor_lock.s"
.include "delay_a.s"

pictures:
	.word earth_low,earth_high

.include "earth.inc"

.align $100

ship_sprite:
	; l0:     0   1   2   3   4   5   6
	.byte	$00,$00,$00,$ff,$00,$00,$00
	; l1:
	.byte	$00,$00,$00,$ff,$00,$00,$00
	; l2:
	.byte	$00,$00,$00,$ff,$00,$00,$00
	; l3:
	.byte	$00,$00,$00,$ff,$00,$00,$00
	; l4:
	.byte	$00,$00,$00,$77,$00,$00,$00
	; l5:
	.byte	$00,$00,$00,$ff,$ff,$22,$00
	; l6:
	.byte	$00,$00,$22,$ff,$ff,$22,$00
	; l7:
	.byte	$00,$dd,$66,$11,$22,$22,$00
	; l8:
	.byte	$dd,$99,$22,$44,$44,$22,$22
	; l9:
	.byte	$99,$11,$66,$ff,$ff,$22,$22
	; l10:
	.byte	$dd,$99,$22,$ff,$ff,$22,$22
	; l11:
	.byte	$00,$dd,$66,$77,$77,$77,$ff
	; l12:
	.byte	$00,$00,$22,$ff,$ff,$77,$ff
	; l13:
	.byte	$00,$00,$00,$ff,$ff,$77,$ff

