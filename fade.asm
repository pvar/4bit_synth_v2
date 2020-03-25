; ****************************************************************
; * fading of main LED for initial program state
; ****************************************************************

dimming_cycle:
	mov tmp3, tmp2							;
	lsl tmp3								;
	andi tmp3, 0b11111110					;
	ldi tmp1, 0b11111110					; create a triangle wave from tmp2 values
	sbrs tmp2, 7							;
	ldi tmp1, 0b00000001					;
	eor tmp3, tmp1							;

	ori tmp3, 1								; never zero

	; --- "high" part of PWM cycle ----------
	sbi PORTD, 4							; turn LED on
	rcall delay								; delay

	; --- "low" part of PWM cycle -----------
	cbi PORTD, 4							; turn LED off
	com tmp3								;
	rcall delay								; complementary delay

	; --- repetition coutner ----------------
	inc tmp4								; increase counter
	brne dimming_cycle						; if counter cleared (after overflowing) stop looping

	; --- change dimming level --------------
	ldi tmp3, 10							;
	add tmp2, tmp3							; change diming level
	ret
