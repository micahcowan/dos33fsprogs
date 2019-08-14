; Handle blast

blast0_out:		.byte $0
blast0_start:		.byte $0
blast0_end:		.byte $0
blast0_y:		.byte $0
blast0_direction:	.byte $0
blast0_count:		.byte $0

	;=========================
	; fire blast
	;=========================

fire_blast:

	lda	blast0_out
	bne	done_fire_blast

	; activate blast slot

	inc	blast0_out

	; reset count

	lda	#0
	sta	blast0_count

	; set y

	lda	PHYSICIST_Y
	clc
	adc	#4
	sta	blast0_y

	; set direction

	lda	DIRECTION
	sta	blast0_direction

	beq	blast_left
	bne	blast_right

	; set x

blast_left:

	ldx	PHYSICIST_X
	dex
	stx	blast0_end

	txa
	sec
	sbc	#10
	sta	blast0_start

	jmp	done_fire_blast

blast_right:

	lda	PHYSICIST_X
	clc
	adc	#5
	sta	blast0_start

	clc
	adc	#10
	sta	blast0_end

done_fire_blast:
	rts


	;====================
	; draw blast
	;====================

draw_blast:

	lda	blast0_out
	beq	done_draw_blast

	lda	#$f6
	sta	hlin_color_smc+1

	lda	#$00
	sta	hlin_mask_smc+1

	ldy	blast0_y

	sec
	lda	blast0_end
	sbc	blast0_start
	tax

	lda	blast0_start

	jsr	hlin

done_draw_blast:

	rts



	;===================
	; move blast
	;===================
move_blast:
	lda	blast0_out
	beq	done_move_blast

	; slow down blast
	lda	blast0_count
	and	#$3
	bne	no_move_blast

	lda	blast0_direction
	bne	move_blast_right

move_blast_left:

	lda	blast0_count
	cmp	#4
	bcc	still_starting_blast_left
	cmp	#8
	bcc	still_shooting_blast_left

continue_shooting_blast_left:
still_shooting_blast_left:

	lda	blast0_end
	sec
	sbc	#10
	sta	blast0_end

still_starting_blast_left:

	lda	blast0_start
	sec
	sbc	#10
	sta	blast0_start

blast_edge_detect_left:

	lda	blast0_end
	bmi	disable_blast

	lda	blast0_start
	bpl	no_move_blast

	lda	#0
	sta	blast0_start

	jmp	no_move_blast


move_blast_right:

	lda	blast0_count
	cmp	#4
	bcc	still_starting_blast_right
	cmp	#8
	bcc	still_shooting_blast_right

continue_shooting_blast_right:
	lda	blast0_start
	clc
	adc	#10
	sta	blast0_start

still_shooting_blast_right:
	lda	blast0_end
	clc
	adc	#10
	sta	blast0_end

still_starting_blast_right:

blast_edge_detect_right:

	; detect if totally off screen
	lda	blast0_start
	cmp	#40
	bcs	disable_blast

	lda	blast0_end
	cmp	#40
	bcc	no_move_blast

	lda	#39
	sta	blast0_end

no_move_blast:
	inc	blast0_count

done_move_blast:

	rts

disable_blast:
	lda	#0
	sta	blast0_out
	rts

