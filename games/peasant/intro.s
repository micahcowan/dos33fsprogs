; Peasant's Quest Intro Sequence

; by Vince `deater` Weaver	vince@deater.net

; with apologies to everyone

.include "hardware.inc"
.include "zp.inc"

.include "qload.inc"
.include "music.inc"

peasant_quest_intro:

	lda	#0
	sta	ESC_PRESSED

	jsr	hgr_make_tables

	jsr	hgr2


	;*******************************
	; restart music, only drum loop
	;******************************

	lda	SOUND_STATUS
	and	#SOUND_MOCKINGBOARD
	beq	mockingboard_notfound

	; hack! modify the PT3 file to ignore the latter half

	lda	#$ff			; end after 4 patterns
	sta	PT3_LOC+$C9+$4

	lda	#$0			; set LOOP to 0
	sta	PT3_LOC+$66

	jsr	pt3_init_song

	cli
mockingboard_notfound:

	;************************
	; Cottage
	;************************

	jsr	cottage

	lda	ESC_PRESSED
	bne	escape_handler

	;************************
	; Lake West
	;************************

	jsr	lake_west

	lda	ESC_PRESSED
	bne	escape_handler

	;************************
	; Lake East
	;************************

	jsr	lake_east

	lda	ESC_PRESSED
	bne	escape_handler

	;************************
	; River
	;************************

	jsr	river

	lda	ESC_PRESSED
	bne	escape_handler

	;************************
	; Knight
	;************************

	jsr knight

	;************************
	; Start actual game
	;************************

	jsr	draw_peasant

	; wait a bit

	lda	#10
	jsr	wait_a_bit

escape_handler:

	;==========================
	; disable music

	lda	SOUND_STATUS
	and	#SOUND_MOCKINGBOARD
	beq	mockingboard_notfound2

	sei				; turn off music
	jsr	clear_ay_both		; clear AY state

	jsr	mockingboard_disable_interrupt
mockingboard_notfound2:



	;=============================
	; start new game
	;=============================

	jmp	start_new_game

.include "new_game.s"


;.include "wait_keypress.s"

.include "intro_cottage.s"
.include "intro_lake_w.s"
.include "intro_lake_e.s"
.include "intro_river.s"
.include "intro_knight.s"

.include "draw_peasant.s"

;.include "decompress_fast_v2.s"
;.include "hgr_font.s"
;.include "draw_box.s"
;.include "hgr_rectangle.s"
;.include "hgr_1x28_sprite.s"
;.include "hgr_partial_save.s"
;.include "hgr_input.s"
;.include "hgr_tables.s"
;.include "hgr_text_box.s"
;.include "hgr_hgr2.s"

.include "hgr_1x5_sprite.s"


.include "gr_copy.s"

.include "wait.s"
.include "wait_a_bit.s"

.include "graphics_peasantry/graphics_intro.inc"

.include "graphics_peasantry/priority_intro.inc"

skip_text:
        .byte 0,2,"ESC Skips",0

	;===================
        ; print title
intro_print_title:
	lda	#<peasant_text
	sta	OUTL
	lda	#>peasant_text
	sta	OUTH

	jsr	hgr_put_string

	lda	#<skip_text
	sta	OUTL
	lda	#>skip_text
	sta	OUTH

	jmp	hgr_put_string		; tail call


