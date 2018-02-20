; LZ4 data decompressor for Apple II
; Based heavily on code by Peter Ferrie (peter.ferrie@gmail.com)

; For LZ4 reference see
; https://github.com/lz4/lz4/wiki/lz4_Frame_format.md

src	EQU $00
dst	EQU $02
end	EQU $04
count	EQU $06
delta	EQU $08
A1L	EQU $3c
A1H	EQU $3d
A2L	EQU $3e
A2H	EQU $3f
A4L	EQU $42
A4H	EQU $43

size	EQU 794
orgoff	EQU $6000	; offset of first unpacked byte
paksize	EQU size-$b-8
			; size of packed data
			; minus 4 for checksum at end
			; not sure what other 4 is from?
			; block checksum? though had that disabled?

pakoff EQU $400b	; 11 byte offset to data?


lz4_decode:
	lda	#<pakoff 		; packed data offset
	sta	src
	lda	#<(pakoff+paksize)	; packed data size
	sta	end
	lda	#>pakoff
	sta	src+1
	lda	#>(pakoff+paksize)
	sta	end+1
	lda	#>orgoff		; original unpacked data offset
	sta	dst+1
	lda	#<orgoff
	sta	dst


; Should: check for magic number 04 22 4d 18
;	FLG: 64 in our case (01=version, block.index=1, block.checksum=0
;		size=0, checksum=1, reserved
;	MAX Blocksize: 40 (64kB)
;	HEADER CHECKSUM: a7
;	BLOCK HEADER: 4 bytes (le)  If highest bit set, uncompressed!


unpmain:
	ldy	#0			; used to index

parsetoken:
	jsr	getsrc			; get next token
	pha				; save for later (need bottom 4 bits)

	lsr				; number of literals in top 4 bits
	lsr				; so shift into place
	lsr
	lsr
	beq	copymatches		; if zero, then no literals

	jsr	buildcount
	tax
	jsr	docopy
	lda	src
	cmp	end
	lda	src+1
	sbc	end+1
	bcs	done

copymatches:
	jsr	getsrc			; get 16-bit delta value
	sta	delta
	jsr	getsrc
	sta	delta+1

	pla				; restore token
	and	#$0f			; get bottom 4 bits
					; match count.  0 means 4
					; 15 means 19+, must be calculated
	jsr	buildcount

	clc
	adc	#4			; adjust count by 4 (minmatch)

	tax
	bcc	copy_skip
	inc	count+1
copy_skip:
	lda	src+1
	pha
	lda	src
	pha
	sec
	lda	dst
	sbc	delta
	sta	src
	lda	dst+1
	sbc	delta+1
	sta	src+1
	jsr	docopy
	pla
	sta	src
	pla
	sta	src+1
	jmp	parsetoken

done:
	pla
	rts




	;=========
	; getsrc
	;=========
getsrc:
	lda	(src), Y		; get a byte from src
	inc	src			; increment pointer
	bne	done_getsrc		; update 16-bit pointer
	inc	src+1			; on 8-bit overflow
done_getsrc:
	rts

	;============
	; buildcount
	;============
buildcount:
	ldx	#1
	stx	count+1
	cmp	#$0f
	bne	done_buildcount
minus_buildcount:
	sta	count
	jsr	getsrc
	tax
	clc
	adc	count
	bcc	skip_buildcount
	inc	count+1
skip_buildcount:
	inx
	beq	minus_buildcount
done_buildcount:
	rts

	;============
	; getput
	;============
	; gets a byte, then puts the byte
getput:
	jsr	getsrc
	; fallthrough to putdst

	;=============
	; putdst
	;=============
putdst:
	sta 	(dst), Y
	inc	dst
	bne	putdst_end
	inc	dst+1
putdst_end:
	rts

	;================
	; docopy
	;================
docopy:
	jsr	getput
	dex
	bne	docopy
	dec	count+1
	bne	docopy
	rts

