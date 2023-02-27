; VMW Productions HIRES/ZX02 image viewer
;
; by deater (Vince Weaver) <vince@deater.net>

; todo help menu, timed slideshow mode
;	move to being a bootsector

.include "zp.inc"
.include "hardware.inc"

WHICH = $E0

hires_start:

	;===================
	; Init RTS disk code
	;===================

	jsr	rts_init

	;===================
	; set graphics mode
	;===================
	jsr	HOME

	bit	HIRES
	bit	FULLGR
	bit	SET_GR
	bit	PAGE0

	lda	#0
	sta	WHICH

	;===================
	; Load graphics
	;===================
load_loop:

	;=============================

	ldx	WHICH

	lda	filenames_low,X
	sta	OUTL
	lda	filenames_high,X
	sta	OUTH

	jsr	load_image

wait_until_keypress:
	lda	KEYPRESS				; 4
	bpl	wait_until_keypress			; 3
	bit	KEYRESET	; clear the keyboard buffer

	cmp	#$88		; left button
	bne	inc_which

	dec	WHICH
	bpl	which_ok

	ldx	#(MAX_FILES-1)
	bne	store_which		; bra

inc_which:
	inc	WHICH
	ldx	WHICH
	cpx	#MAX_FILES
	bcc	which_ok		; blt

	ldx	#0
store_which:
	stx	WHICH

which_ok:
	jmp	load_loop


	;==========================
	; Load Image
	;===========================

load_image:
	jsr	opendir_filename	; open and read entire file into memory

	; size in ldsizeh:ldsizel (f1/f0)

	comp_data	= $a000
	out_addr	= $2000


	jsr	full_decomp

	rts

	.include	"zx02_optim.s"
	.include	"rts.s"

;
