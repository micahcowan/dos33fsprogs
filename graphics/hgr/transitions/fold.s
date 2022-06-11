; When to fold them


; zero page
GBASL	= $26
GBASH	= $27
YY	= $69
ROW_SUM = $70

HGR_X           = $E0
HGR_XH          = $E1
HGR_Y           = $E2
HGR_COLOR       = $E4
HGR_PAGE        = $E6

OUTL = $FD
OUTH = $FE
LINE = $FF

; soft-switches
FULLGR	= $C052
PAGE1	= $C054

; ROM routines

HGR2	= $F3D8
HGR	= $F3E2
HPOSN	= $F411		; (Y,X),(A)  (values stores in HGRX,XH,Y)

WAIT    = $FCA8                 ;; delay 1/2(26+27A+5A^2) us

	;================================
	; Clear screen and setup graphics
	;================================
bars:

	jsr	HGR		; set hi-res 140x192, page2, fullscreen
				; A and Y both 0 at end


	; copy in some nonsense

;	ldy	#0
;loop:
;src_smc:
;	lda	$d000,Y
;dst_smc:
;	sta	$4000,Y
;	dey
;	bne	loop

;	inc	src_smc+2
;	inc	dst_smc+2
;	lda	dst_smc+2
;	cmp	#$60
;	bne	loop

	lda	#$d0
	sta	OUTH
	lda	#$00
	sta	OUTL

	ldy	#0
	sty	LINE

line_loop:
	lda	LINE
	jsr	HPOSN		; (Y,X),(A)  (values stores in HGRX,XH,Y)

	; first top right
	ldy	#39
out_loop:
	lda	(OUTL),Y
	sta	(GBASL),Y

	dey
	bpl	out_loop

	inc	LINE
	lda	LINE
	cmp	#192
	bne	line_loop

end:
	jmp	end
