; Display the TFV title screen
;
; this is the opener, title screen, new game creation, and load game code

.include "zp.inc"
.include "hardware.inc"
.include "common_defines.inc"

	;================================
	; Clear screen and setup graphics
	;================================

	jsr	HOME
	bit	PAGE0			; set page 0
	bit	LORES			; Lo-res graphics
	bit	TEXTGR			; mixed gr/text mode
	bit	SET_GR			; set graphics

	lda	#0
	sta	DISP_PAGE
	lda	#4
	sta	DRAW_PAGE

	;===================================
	; Clear top/bottom of page 0 and 1
	;===================================

	jsr	clear_screens

	;==========================
	; Do Opening
	;==========================

	jsr	opening

	;======================
	; show the title screen
	;======================

	; Title Screen

title_screen:

	;===========================
	; Clear both bottoms

	jsr     clear_bottoms

	;=============================
	; Load title

	lda     #<(title_lzsa)
        sta     getsrc_smc+1
	lda     #>(title_lzsa)
	sta	getsrc_smc+2

	lda	#$0c

	jsr     decompress_lzsa2_fast

	;=================================
	; copy to both pages

	jsr	gr_copy_to_current
	jsr	page_flip
	jsr	gr_copy_to_current

	lda	#20
	sta	YPOS
	lda	#20
	sta	XPOS


	;=================================
	; title menu loop
	;=================================

	lda	#0
	sta	menu_offset
	lda	#2
	sta	menu_max
title_menu_loop:
	lda	#<title_menu
	sta	OUTL
	lda	#>title_menu
	sta	OUTH

	jsr	draw_menu

	jsr	page_flip

	jsr	increment_frame

	lda	MENU_RESULT
	bmi	title_menu_loop

	; space was pressed!

	beq	title_new_game
	cmp	#1
	beq	title_load_game
	bne	title_load_credits


	;=================================
	; new game started!
	;=================================
title_new_game:

	;=================================
	; enter name

	jsr	enter_name

	; TODO: all rest

	lda	#LOAD_FLYING
	sta	WHICH_LOAD

	rts

	;=================================
	; load game!  for now, debugging
	;=================================
title_load_game:
	lda	#LOAD_FLYING
	sta	WHICH_LOAD

	rts

	;=================================
	; load credits!
	;=================================
title_load_credits:
	lda	#LOAD_CREDITS
	sta	WHICH_LOAD

	rts



	;===============================
	; increment frame
	;===============================
increment_frame:
	inc	FRAMEL
	bne	done_increment_frame
	inc	FRAMEH
done_increment_frame:
	rts

;===============================================
; External modules
;===============================================

.include "tfv_opener.s"

.include "gr_pageflip.s"
.include "text_print.s"
.include "gr_fast_clear.s"
.include "gr_vlin.s"
.include "gr_copy.s"
.include "decompress_fast_v2.s"
.include "gr_offsets.s"
.include "wait_keypressed.s"
.include "tfv_textentry.s"

.include "keyboard.s"
.include "joystick.s"
.include "draw_menu.s"

;===============================================
; Data
;===============================================

title_menu:
	.byte   16,21,"NEW GAME",0
	.byte   16,22,"LOAD GAME",0
	.byte   16,23,"CREDITS",0
	.byte   255

enter_name_string:
	.asciiz	"PLEASE ENTER A NAME:"

name:
	.byte $0,$0,$0,$0,$0,$0,$0,$0

.include "graphics_title/tfv_title.inc"
