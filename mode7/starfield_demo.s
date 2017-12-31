.include "zp.inc"

;===========
; CONSTANTS
;===========

NUMSTARS	EQU	16


	;=====================
	; Starfield
	;=====================

	;================================
	; Clear screen and setup graphics
	;================================

	jsr	clear_screens		 ; clear top/bottom of page 0/1
	jsr     set_gr_page0

	; Initialize the 2kB of multiply lookup tables
	jsr	init_multiply_tables


	;===============
	; Init Variables
	;===============
	lda	#0
	sta	DRAW_PAGE
	sta	RANDOM_POINTER

	ldy	#(NUMSTARS-1)
init_stars:
	jsr	random_star
	dey
	bpl	init_stars

	;===========================
	;===========================
	; Main Loop
	;===========================
	;===========================

starfield_loop:

	;===============
	; clear screen
	;===============
	jsr	clear_top

	;===============
	; draw stars
	;===============


	; start at 15 and count down (rather than 0 and count up)
	ldx	#(NUMSTARS-1)

draw_stars:
	stx	XX

	;================
	; calculate color
	;================

	lda	#$ff		; want if z<16, color = 5
	sta	COLOR		; 	if 16<z<32 color = 13
				;	if 32<z<64 color = 15
	ldy	XX
	lda	star_z,Y
	tay			; put star_z[i] in Y for later

	cmp	#32
	bpl	done_color

	cmp	#16		; 15 -1 16 0 17 1
	bpl	second_color

	lda	#$55
	sta	COLOR

	jmp	done_color
second_color:
	lda	#$dd
	sta	COLOR

done_color:


	; calculate x value, stars[i].x/stars[i].z

	; put 1/stars[i].z in NUM1H:NUM1L and multiply

	lda	z_table,Y
	sta	NUM1L		; F

	; adjust for 58+
	; all this logic to avoid having a 128 byte table of mostly zero
	lda	#0		; I
	clc
	cpy	#60		; 59 -1 60 0 61 1
	bmi	no_adjust
	adc	#1		; 60, 61 = 1
	cpy	#62		; 61 -1 62 0 63 1
	bmi	no_adjust
	adc	#1		; 62 = 2
	cpy	#63		; 62 = -1 63 = 0 64 = not possible
	bne	no_adjust
	adc	#2		; 63 = 4
no_adjust:
	sta	NUM1H

	; load stars[i].x into NUM2H:NUM2L
	; NUM2L is always zero
	ldy	XX

	lda	star_x,Y
	sta	NUM2H

	lda	#0
	sta	NUM2L
	sec			; don't reuse old values
	jsr	multiply

	; integer result in X
	txa
	clc
	adc	#20

	sta	XPOS

	; calculate y value, stars[i].y/stars[i].z

	; 1/stars[i].z is still in NUM1H:NUM1L

	ldy	XX

	lda	star_y,Y
	sta	NUM2H
	lda	#0
	sta	NUM2L
	clc			; reuse old values
	jsr	multiply

	; integer result in X
	txa
	clc
	adc	#20

	tay			; Y is YPOS
	sty	YPOS		; put Y value in Y to plot


	;============================
	; Check Limits
	;============================

	lda	XPOS
	bmi	new_star
	cmp	#40
	bpl	new_star

	ldy	YPOS
	bmi	new_star
	cpy	#40
	bpl	new_star

	; FIXME: sort out all of these jumps to be more efficient
	jmp	plot_star

new_star:
	ldy	XX
	jsr	random_star

	jmp	plot_star_continue

plot_star:
	;================================
	; plot routine
	;================================
	; put address in GBASL/GBASH
	; Xcoord in XPOS
	; Ycoord in Y


	tya
	and	#$fe
	tay

	lda	gr_offsets,Y	; lookup low-res memory address		; 4
        clc								; 2
        adc	XPOS							; 3
        sta	GBASL							; 3
        iny								; 2

        lda	gr_offsets,Y                                            ; 4
        adc	DRAW_PAGE	; add in draw page offset		; 3
        sta	GBASH							; 3
								;===========
								;
	ldy	#0
	lda	YPOS
	and	#$1
	bne	plot_odd
plot_even:
	lda	COLOR
	and	#$0f
	sta	COLOR
	lda	(GBASL),Y
	and	#$f0
	jmp	plot_write
plot_odd:
	lda	COLOR
	and	#$f0
	sta	COLOR
	lda	(GBASL),Y
	and	#$0f
plot_write:
	ora	COLOR
	sta	(GBASL),Y

plot_star_continue:

	;==============================
	ldx	XX

	dex
	bmi	starfield_keyboard
;	bpl	draw_stars
	jmp	draw_stars

starfield_keyboard:

	jsr	get_key		; get keypress				; 6

	lda	LASTKEY							; 3

	cmp	#('Q')		; if quit, then return
	bne	skipskip
	rts

skipskip:

	;==================
	; flip pages
	;==================

	jsr	page_flip						; 6

	;==================
	; loop forever
	;==================
blah:
	jmp blah

;	jmp	starfield_loop						; 3


; matches scroll_row1 - row3
star_x	EQU	$8A00
star_y	EQU	$8B00
star_z	EQU	$8C00

	;===================
	; star number in Y
	; FIXME: increment at end?
	; X trashed
random_star:
	; random x location
	ldx	RANDOM_POINTER
	lda	random_table,X
	inc	RANDOM_POINTER
	sta	star_x,Y

	; random y location
	ldx	RANDOM_POINTER
	lda	random_table,X
	inc	RANDOM_POINTER
	sta	star_y,Y

	; random z location
	ldx	RANDOM_POINTER
	lda	random_table,X
	inc	RANDOM_POINTER
	and	#$3f
	sta	star_z,Y

	rts

;===============================================
; External modules
;===============================================

.include "../asm_routines/hlin_clearscreen.s"
.include "../asm_routines/pageflip.s"
.include "../asm_routines/gr_setpage.s"
.include "../asm_routines/keypress.s"
.include "../asm_routines/gr_putsprite.s"
.include "../asm_routines/text_print.s"

;===============================================
; Variables
;===============================================


.include "../asm_routines/multiply_fast.s"


;======================
; some "random" numbers
;======================
random_table:
	.byte	103,198,105,115, 81,255, 74,236, 41,205,186,171,242,251,227, 70
	.byte	124,194, 84,248, 27,232,231,141,118, 90, 46 ,99, 51,159,201,154
	.byte	102, 50, 13,183, 49, 88,163, 90, 37, 93,  5, 23, 88,233, 94,212
	.byte	171,178,205,198,155,180, 84, 17, 14,130,116, 65, 33, 61,220,135
	.byte	112,233, 62,161, 65,225,252,103, 62,  1,126,151,234,220,107,150
	.byte	143, 56, 92, 42,236,176, 59,251, 50,175, 60, 84,236, 24,219, 92
	.byte     2, 26,254, 67,251,250,170, 58,251, 41,209,230,  5, 60,124,148
	.byte	117,216,190, 97,137,249, 92,187,168,153, 15,149,177,235,241,179
	.byte	  5,239,247,  0,233,161, 58,229,202, 11,203,208, 72, 71,100,189
	.byte	 31, 35, 30,168, 28,123,100,197, 20,115, 90,197, 94, 75,121, 99
	.byte	 59,112,100, 36, 17,158,  9,220,170,212,172,242, 27, 16,175, 59
	.byte	 51,205,227, 80, 72, 71, 21, 92,187,111, 34, 25,186,155,125,245
	.byte	 11,225, 26, 28,127, 35,248, 41,248,164, 27, 19,181,202, 78,232
	.byte	152, 50, 56,224,121, 77, 61, 52,188, 95, 78,119,250,203,108,  5
	.byte	172,134, 33, 43,170, 26, 85,162,190,112,181,115, 59,  4, 92,211
	.byte	 54,148,179,175,226,240,228,158, 79, 50, 21, 73,253,130, 78,169

z_table:
	; 1/16.0 - 1/12.25
	.byte	$10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$13,$13,$14,$14,$14
	; 1/12.0 - 1/8.25
	.byte	$15,$15,$16,$16,$17,$17,$18,$18,$19,$1A,$1A,$1B,$1C,$1D,$1E,$1F
	; 1/8.0 - 1/4.25
	.byte	$20,$21,$22,$23,$24,$25,$27,$28,$2A,$2C,$2E,$30,$33,$35,$38,$3C
	; 1/4.0 - 1/0.25
	.byte	$40,$44,$49,$4E,$55,$5D,$66,$71,$80,$92,$AA,$CC,$00,$55,$00,$00

