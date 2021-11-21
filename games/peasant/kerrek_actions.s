; notes
; walk into footprint land
; if kerrek alive
;	odds of kerrek there  are ??? 50/50?
; if kerrek dead
;	if dead on this screen
;	if dead not on this screen


kerrek_setup:
	; first see if Kerrek alive
	lda	KERREK_STATE
	and	#$f
	bne	kerrek_setup_dead

kerrek_setup_alive:
	jsr	random16
	and	#$1
	beq	kerrek_alive_not_there
kerrek_alive_out:

	lda	#20
	sta	KERREK_X
	lda	#100
	sta	KERREK_Y
	lda	#0
	sta	KERREK_DIRECTION
	lda	#1
	sta	KERREK_SPEED

	lda	MAP_LOCATION
	cmp	#LOCATION_KERREK_1
	bne	kerrek_there

	lda	KERREK_STATE
	ora	#KERREK_ROW1
	sta	KERREK_STATE

kerrek_there:
	lda	KERREK_STATE
	ora	#KERREK_ONSCREEN
	sta	KERREK_STATE

	rts

kerrek_alive_not_there:

kerrek_not_there:
	lda	KERREK_STATE
	and	#(~KERREK_ONSCREEN)
	sta	KERREK_STATE
	rts

kerrek_setup_dead:

	; see if on this screen

	lda	KERREK_STATE
	and	#KERREK_ROW1
	beq	kerrek_row4
kerrek_row1:
	lda	MAP_LOCATION
	cmp	#LOCATION_KERREK_1
	beq	kerrek_there
	bne	kerrek_not_there

kerrek_row4:
	lda	MAP_LOCATION
	cmp	#LOCATION_KERREK_2
	beq	kerrek_there
	bne	kerrek_not_there

	rts


	;=======================
	;=======================
	;=======================
	; Kerrek
	;=======================
	;=======================
	;=======================

kerrek_verb_table:
	.byte VERB_GET
	.word kerrek_get-1
	.byte VERB_TAKE
	.word kerrek_get-1
	.byte VERB_LOAD
	.word kerrek_load-1
	.byte VERB_SAVE
	.word kerrek_save-1
	.byte VERB_LOOK
	.word kerrek_look-1
	.byte VERB_SHOOT
	.word kerrek_shoot-1
	.byte VERB_KILL
	.word kerrek_kill-1
	.byte VERB_TALK
	.word kerrek_talk-1
	.byte VERB_MAKE
	.word kerrek_make-1
	.byte VERB_BUY
	.word kerrek_buy-1
	.byte 0

	;=================
	; get
	;=================
kerrek_get:

	lda	CURRENT_NOUN

	cmp	#NOUN_KERREK
	beq	kerrek_get_kerrek
	cmp	#NOUN_ARROW
	beq	kerrek_get_arrow
	cmp	#NOUN_BELT
	beq	kerrek_get_belt

kerrek_cant_get:
	jmp	parse_common_get

kerrek_get_kerrek:
	ldx	#<kerrek_get_kerrek_message
	ldy	#>kerrek_get_kerrek_message
	jmp	finish_parse_message

kerrek_get_arrow:
	; only if kerrek dead and on screen

	lda	KERREK_STATE
	bpl	kerrek_cant_get
	and	#$f
	beq	kerrek_cant_get

	ldx	#<kerrek_get_arrow_message
	ldy	#>kerrek_get_arrow_message
	jmp	finish_parse_message

kerrek_get_belt:

	; only if kerrek dead and on screen

	lda	KERREK_STATE
	bpl	kerrek_cant_get
	and	#$f
	beq	kerrek_cant_get

	lda	INVENTORY_1
	and	#INV1_KERREK_BELT
	bne	kerrek_get_belt_already

kerrek_get_belt_finally:
	; get belt
	; add 10 to score

	lda	INVENTORY_1
	ora	#INV1_KERREK_BELT
	sta	INVENTORY_1

	lda	#10
	jsr	score_points

	ldx	#<kerrek_get_belt_message
	ldy	#>kerrek_get_belt_message
	jmp	finish_parse_message

kerrek_get_belt_already:
	ldx	#<kerrek_get_belt_already_message
	ldy	#>kerrek_get_belt_already_message
	jmp	finish_parse_message


	;=================
	; buy
	;=================
kerrek_buy:

	lda	CURRENT_NOUN
	cmp	#NOUN_KERREK
	bne	kerrek_buy_not_there

	lda	KERREK_STATE
	bpl	kerrek_buy_not_there

	lda	KERREK_STATE
	and	#$f
	bne	kerrek_buy_not_there

	inc	KERREK_SPEED

	ldx	#<kerrek_buy_cold_one_message
	ldy	#>kerrek_buy_cold_one_message
	jmp	finish_parse_message

kerrek_buy_not_there:
	jmp	parse_common_unknown


	;=================
	; make
	;=================
kerrek_make:
	lda	CURRENT_NOUN
	cmp	#NOUN_KERREK
	bne	kerrek_make_not_there

	lda	KERREK_STATE
	bpl	kerrek_make_not_there

	lda	KERREK_STATE
	and	#$f
	bne	kerrek_make_not_there

	ldx	#<kerrek_make_friends_message
	ldy	#>kerrek_make_friends_message
	jmp	finish_parse_message

kerrek_make_not_there:
	jmp	parse_common_unknown

	;=================
	; talk
	;=================
kerrek_talk:
	lda	CURRENT_NOUN
	cmp	#NOUN_KERREK
	bne	kerrek_talk_not_there

	lda	KERREK_STATE
	bpl	kerrek_talk_not_there

	lda	KERREK_STATE
	and	#$f
	bne	kerrek_talk_not_there

kerrek_there_talk:
	ldx	#<kerrek_talk_message
	ldy	#>kerrek_talk_message
	jmp	finish_parse_message

kerrek_talk_not_there:
	jmp	parse_common_talk



	;=================
	; load/save
	;=================
kerrek_load:
	lda	KERREK_STATE
	bmi	kerrek_load_there
	jmp	parse_common_load
kerrek_load_there:
	ldx	#<kerrek_load_save_message
	ldy	#>kerrek_load_save_message
	jmp	finish_parse_message

kerrek_save:
	lda	KERREK_STATE
	bmi	kerrek_load_there
	jmp	parse_common_save

	;=================
	; kill/shoot
	;=================
kerrek_kill:
kerrek_shoot:

	rts


	;=================
	; look
	;=================

kerrek_look:

	; first see if kerrek is on screen

	lda	KERREK_STATE
	bpl	kerrek_look_not_there

kerrek_look_there:

	; check if there and alive

	lda	KERREK_STATE
	and	#$f
	bne	kerrek_look_there_dead

kerrek_look_there_alive:

	; see what we're looking at

	lda	CURRENT_NOUN

	cmp	#NOUN_BELT
	beq	kerrek_look_belt_alive

	; kerrek was there and alive
kerrek_look_there_alive_everything_else:
	ldx	#<kerrek_look_kerrek_message
	ldy	#>kerrek_look_kerrek_message
	jmp	finish_parse_message

kerrek_look_belt_alive:
	ldx	#<kerrek_look_belt_alive_message
	ldy	#>kerrek_look_belt_alive_message
	jmp	finish_parse_message


kerrek_look_there_dead:
	; kerrek was there and dead
	; already masked off

	cmp	#KERREK_DEAD
	beq	kerrek_look_there_dead_dead
	cmp	#KERREK_DECOMPOSING
	beq	kerrek_look_there_dead_decomposing
;	cmp	#KERREK_SKELETON


	;============================
	; look, kerrek is a skeleton
	;============================

	; here is kerrek a skeleton
kerrek_look_there_dead_bones:
	lda	CURRENT_NOUN
	cmp	#NOUN_BONE
	beq	kerrek_look_there_dead_bones_bones
	cmp	#NOUN_KERREK
	beq	kerrek_look_there_dead_bones_kerrek

kerrek_look_there_dead_bones_default:
	; typed "look" after kerrek a skeleton
	ldx	#<kerrek_look_kerrek_bones_message
	ldy	#>kerrek_look_kerrek_bones_message
	jmp	finish_parse_message

kerrek_look_there_dead_bones_kerrek:
	; typed "look kerrek" after kerrek a skeleton

	ldx	#<kerrek_look_bones_kerrek_message
	ldy	#>kerrek_look_bones_kerrek_message
	jmp	finish_parse_message

kerrek_look_there_dead_bones_bones:
	; typed "look bones" after kerrek a skeleton

	ldx	#<kerrek_look_bones_message
	ldy	#>kerrek_look_bones_message
	jmp	finish_parse_message


	;==============================
	; look, kerrek is freshly dead
	;==============================

kerrek_look_there_dead_dead:
	lda	CURRENT_NOUN
	cmp	#NOUN_KERREK
	beq	kerrek_look_there_dead_look_kerrek

	; typed "look" when kerrek just killed
kerrek_look_there_dead_look:
	ldx	#<kerrek_look_dead_message
	ldy	#>kerrek_look_dead_message
	jmp	finish_parse_message


	; typed "look kerrek" when kerrek just killed
kerrek_look_there_dead_look_kerrek:

	; see if belt there

	lda	INVENTORY_1
	and	#INV1_KERREK_BELT
	bne	kerrek_look_there_dead_look_kerrek_no_belt

kerrek_look_there_dead_look_kerrek_belt:
	ldx	#<kerrek_look_kerrek_dead_message
	ldy	#>kerrek_look_kerrek_dead_message
	jmp	finish_parse_message

kerrek_look_there_dead_look_kerrek_no_belt:
	ldx	#<kerrek_look_kerrek_dead_nobelt_message
	ldy	#>kerrek_look_kerrek_dead_nobelt_message
	jmp	finish_parse_message


	;==============================
	; look, kerrek is decomposing
	;==============================

	; here if kerrek is in decompsing state
kerrek_look_there_dead_decomposing:
	lda	CURRENT_NOUN
	cmp	#NOUN_KERREK
	beq	kerrek_look_there_dead_decomposing_kerrek

	; here if "look" when decomposing

	ldx	#<kerrek_look_decomposing_message
	ldy	#>kerrek_look_decomposing_message
	jmp	finish_parse_message

kerrek_look_there_dead_decomposing_kerrek:
	; here if "look kerrek" when decomposing

	ldx	#<kerrek_look_kerrek_decomposing_message
	ldy	#>kerrek_look_kerrek_decomposing_message
	jmp	finish_parse_message


	;==============================
	; look, kerrek is not there
	;==============================

kerrek_look_not_there:

	lda	CURRENT_NOUN

	cmp	#NOUN_FOOTPRINTS
	beq	kerrek_look_footprints
	cmp	#NOUN_TRACKS
	beq	kerrek_look_footprints


	; check if alive elsewhere

	lda	KERREK_STATE
	and	#$f
	bne	kerrek_look_not_there_dead

kerrek_look_not_there_alive:

	ldx	#<kerrek_look_no_kerrek_message
	ldy	#>kerrek_look_no_kerrek_message
	jmp	finish_parse_message

kerrek_look_not_there_dead:

	ldx	#<kerrek_look_no_dead_kerrek_message
	ldy	#>kerrek_look_no_dead_kerrek_message
	jmp	finish_parse_message

kerrek_look_tracks:
kerrek_look_footprints:
	ldx	#<kerrek_look_footprints_message
	ldy	#>kerrek_look_footprints_message
	jmp	finish_parse_message

