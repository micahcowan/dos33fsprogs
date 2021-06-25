; VGI Doom

.include "zp.inc"
.include "hardware.inc"

VGI_MAXLEN	=	7

PT3_LOC = doom_e1_m1

PT3_ENABLE_APPLE_IIC = 1


vgi_doom:
	; Init variables
	lda	#0
	sta	DONE_PLAYING
	lda	#1
	sta	LOOP			; loop forever

	;=======================
	; Detect Apple II Model
	;========================
	; IRQ setup is different on IIc
	; You can possibly skip this if you only care about II+/IIe

.ifdef PT3_ENABLE_APPLE_IIC
	jsr	detect_appleii_model
.endif

	;=======================
	; Detect mockingboard
	;========================

	jsr     print_mockingboard_detect       ; print message

	jsr     mockingboard_detect             ; call detection routine

	bcs     mockingboard_found

	jsr     print_mocking_notfound

	; possibly can't detect on IIc so just try with slot#4 anyway
	; even if not detected

	jmp     setup_interrupt

mockingboard_found:

	; print found message
	; modify message to print slot value

        lda     MB_ADDR_H
        sec
        sbc     #$10
        sta     found_message+11

        jsr     print_mocking_found

        ;==================================================
        ; patch the playing code with the proper slot value
        ;==================================================

        jsr     mockingboard_patch

setup_interrupt:

        ;=======================
        ; Set up 50Hz interrupt
        ;========================

        jsr     mockingboard_init
        jsr     mockingboard_setup_interrupt

	;============================
        ; Init the Mockingboard
        ;============================

        jsr     reset_ay_both
        jsr     clear_ay_both

        ;==================
        ; init song
        ;==================

        jsr     pt3_init_song


	jsr	SETGR
	jsr	HGR
;	bit	FULLGR

	jsr	make_tables


	;============================
        ; Enable 6502 interrupts
        ;============================
start_interrupts:
        cli             ; clear interrupt mask


	; get pointer to image data

	lda	#<doom_data
	sta	VGIL
	lda	#>doom_data
	sta	VGIH

;	lda	#<clock_data
;	sta	VGIL
;	lda	#>clock_data
;	sta	VGIH

	jsr	play_vgi

	jsr	wait_until_keypress



	jsr	CROUT1		; print linefeed/cr

loopy:
	lda	#<string1
	sta	OUTL
	lda	#>string1
	sta	OUTH

	jsr	fake_input
	jsr	fake_input
	jsr	fake_input

done:
	jmp	done


	;==================================
	; play_vgi
	;==================================
play_vgi:

vgi_loop:

	ldy	#0
data_smc:
	lda	(VGIL),Y
	sta	VGI_BUFFER,Y
	iny
	cpy	#VGI_MAXLEN
	bne	data_smc

	lda	TYPE
	and	#$f

	clc
	adc	VGIL
	sta	VGIL
	bcc	no_oflo
	inc	VGIH
no_oflo:

	lda	TYPE
	lsr
	lsr
	lsr
	lsr

	; look up action in jump table
	asl
	tax
	lda	vgi_rts_table+1,X
	pha
	lda	vgi_rts_table,X
	pha
	rts				; "jump" to subroutine

vgi_rts_table:
	.word vgi_clearscreen-1		; 0 = clearscreen
	.word vgi_simple_rectangle-1	; 1 = simple rectangle
	.word vgi_circle-1		; 2 = plain circle
	.word vgi_filled_circle-1	; 3 = filled circle
	.word vgi_point-1		; 4 = dot
	.word vgi_lineto-1		; 5 = line to
	.word vgi_dithered_rectangle-1	; 6 = dithered rectangle
	.word vgi_vertical_triangle-1	; 7 = vertical triangle
	.word vgi_horizontal_triangle-1	; 8 = horizontal triangle
	.word vgi_vstripe_rectangle-1	; 9 = vstripe rectangle
	.word vgi_line-1		;10 = line
	.word vgi_line_far-1		;11 = line far
	.word all_done-1
	.word all_done-1
	.word all_done-1
	.word all_done-1		; 15 = done

all_done:
	rts


.include "vgi_clearscreen.s"
.include "vgi_circles.s"
.include "vgi_rectangle.s"
.include "vgi_lines.s"
.include "vgi_triangles.s"

.include "doom.data"

; string data
;

string1:
.byte "YOU SEE A CLOCK TOWER READING 12:00",13
.byte "     LEFT/RIGHT/FORWARD",13,0

; SWIM TO TOWER
string2:
.byte "YOU DON'T KNOW HOW TO ",34,"SWIM",34,13,0

; WADE TO TOWER
string3:
.byte "THE KRAKEN WILL EAT YOU",13,0

; I AM WILLING TO TAKE THAT RISK

string4:
.byte "YOU SEE A MYSTERIOUS SPACESHIP",13
.byte "     LEFT/RIGHT/FORWARD",13,0

string5:
.byte "YOU ARE CLOSE TO THE SPACESHIP",13
.byte "YOU SEE A DOOR",13,0

; OPEN DOOR

string6:
.byte "THE DOOR IS LOCKED",13
.byte "ATRUS HATES YOU",13,0

;string7:
;.byte "SORRY, I DON'T UNDERSTAND THAT",0

string7:
.byte "YOU SEE A RED BOOK",13
.byte "NEXT TO IT IS A PAGE",13,0

string8:
.byte "WHICH PAGE?",13,0

string9:
.byte "I'D SAY IT'S MORE OF A PURPLE COLOR",13,0

string10:
.byte "THIS IS A MOST UNUSUAL FIREPLACE",13
.byte "THERE ARE MANY BUTTONS HERE",13,0

string11:
.byte "WHICH BUTTON?",13,0

string12:
.byte "THAT WAS NOT THE RIGHT ONE",13,0

; PICK UP PAGE
; WHICH PAGE?
; THE RED ONE
; I'D SAY IT'S MORE OF A PURPLE COLOR
; JUST PICK IT UP!

; THIS WEIRD FIREPLACE HAS MANY BUTTONS

; PRESS BUTTON

; WHICH ONE?

; REALLY?

; WHICH ONE (0..126)

; NOTHING HAPPENS

	;=========================
	; print_string
	;=========================
print_string:
	ldy	#0

print_string_loop:
	lda	(OUTL),Y
	beq	done_print_string

	ora	#$80
	jsr	COUT

	iny

	jmp	print_string_loop

done_print_string:
	tya		; point to next string
	sec
	adc	OUTL
	sta	OUTL
	lda	OUTH
	adc	#0
	sta	OUTH
	rts

	;============================
	; WAIT UNTIL KEYPRESS
	;============================

wait_until_keypress:

	lda	KEYPRESS
	bpl	wait_until_keypress

	bit	KEYRESET

	rts

	;=============================
	; fake input
	;=============================
fake_input:
	jsr	print_string

	jsr	CROUT1		; print linefeed/cr

	lda	#'>'+$80
	jsr	COUT
	lda	#' '+$80
	jsr	COUT

	jsr	GETLN1

	rts

.ifdef PT3_ENABLE_APPLE_IIC
.include        "pt3_lib_detect_model.s"
.endif

.include        "pt3_lib_core.s"
.include        "pt3_lib_init.s"
.include        "pt3_lib_mockingboard_setup.s"
.include        "interrupt_handler.s"
; if you're self patching, detect has to be after interrupt_handler.s
.include        "pt3_lib_mockingboard_detect.s"


	;==================================
	; Print mockingboard detect message
	;==================================
	; note: on IIc must do this before enabling interrupt
	;	as we disable ROM (COUT won't work?)

print_mockingboard_detect:
	lda	APPLEII_MODEL
	sta	apple_message+17

	; print detection message for Apple II type
	ldy	#0
print_apple_message:
	lda	apple_message,Y		; load loading message
	beq	done_apple_message
	ora	#$80
	jsr	COUT
	iny
	jmp	print_apple_message
done_apple_message:
	jsr	CROUT1


	; print detection message
	ldy	#0
print_mocking_message:
	lda	mocking_message,Y		; load loading message
	beq	done_mocking_message
	ora	#$80
	jsr	COUT
	iny
	jmp	print_mocking_message
done_mocking_message:
	jsr	CROUT1

	rts

print_mocking_notfound:

	ldy	#0
print_not_message:
	lda	not_message,Y		; load loading message
	beq	print_not_message_done
	ora	#$80
	jsr	COUT
	iny
	jmp	print_not_message
print_not_message_done:
	rts

print_mocking_found:
	ldy	#0
print_found_message:
	lda	found_message,Y		; load loading message
	beq	done_found_message
	ora	#$80
	jsr	COUT
	iny
	jmp	print_found_message
done_found_message:

	rts

;=========
; strings
;=========
apple_message:		.asciiz "DETECTED APPLE II  "

mocking_message:	.asciiz "LOOKING FOR MOCKINGBOARD: "
not_message:		.byte "NOT "
found_message:		.asciiz "FOUND SLOT#4"




.align $100
doom_e1_m1:
.incbin "doom_e1m1.pt3"
