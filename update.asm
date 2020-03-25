
; ****************************************************************
; * generic update routine (used by all channels)
; ****************************************************************

; total clock-ticks: 82 (without call and ret)

update:	; =================================== (17 clock ticks)
	clr XH									; copy channel's data fromt SRAM to register file
	mov XL, channel_data					;
	ld phase_delta_l, X+					;
	ld phase_delta_h, X+					;
	ld note_ptr_l, X+						;
	ld note_ptr_h, X+						;
	ld duration, X+							;
	ld parameters, X+						;
	ld volume, X							;
	clr tmp4								; cleared all the way through this subroutine

duration_check: ; =========================== (15 clock ticks to apply_effect - 3 clock ticks to ch_update)
	dec duration							; decrease duration
	breq ch_update							; if duration has ended, get next note

	ldi tmp2, 3								; preload volume increase step
	mov tmp1, duration						; copy duration for testing
	cpi tmp1, 7								;
	brlo ch_fade_out						; if duration < 7: decrease volume
	rjmp ch_fade_in							; if duration > 7: increase volume
ch_fade_out:  ; -----------------------------
	nop										;
	mov tmp1, volume						;
	cpi tmp1, 8								; (min level = 8)
	breq no_vol_dec							; if at min level, do not decrease volume
	dec volume								; if not at min level, decrease volume by one
no_vol_dec:
	nop
	rjmp apply_effects						; proceed to effect application
ch_fade_in:  ; ------------------------------
	mov tmp1, volume						;
	cpi tmp1, 15							; (max level = 15)
	breq no_vol_inc							; if at max level, do not increase volume
	add volume, tmp2						; if not at max level, increase volume by three
no_vol_inc:
	nop
	rjmp apply_effects						; proceed to effect application

ch_update: ; ================================ (47 clock ticks to update_end)
	mov ZL, note_ptr_l						; Z points to new_note data (effect, duration and other parameters)
	mov ZH, note_ptr_h						;
	lpm										; get new_note data

	mov parameters, r0						;
	ldi tmp3, 0b11111000					;
	and parameters, tmp3					; keep effect and other parameters

	com tmp3								;
	and r0, tmp3							;
	mov duration, r0						; keep duration

	adiw ZH:ZL, 1							; Z points to new_note pitch
	lpm										; get coresponding phase_delta pointer

	ldi ZH, high(deltas*2)					;
	ldi ZL, low(deltas*2)					;
	add ZL, r0								; add phase_delta pointer to table starting address 
	adc ZH, tmp4							;
	lpm										; get phase delta high-byte for new_note
	mov phase_delta_H, r0					;
	adiw ZH:ZL, 1							;
	lpm										; get phase delta low-byte for new_note
	mov phase_delta_l, r0					;

	ldi ZH, high(durations*2)				;
	ldi ZL, low(durations*2)				;

	mov tmp1, rythm							;
	add tmp1, duration						; add duration and rythm offsets

	add ZL, tmp1							; add total offset to table starting address
	adc ZH, tmp4							;
	lpm										;
	mov duration, r0						; get "decoded" duration

	ldi tmp1, 9								;
	mov volume, tmp1						; set initial volume level

	ldi tmp3, 2								; advance note pointer
	add note_ptr_l, tmp3					; (prepare for next update)
	adc note_ptr_h, tmp4					;

	rjmp update_end							;

apply_effects: ; ============================ (35 clock ticks to update_end)
	nop										;
	nop										;
	nop										;

; light effects -----------------------------
	in tmp1, PORTD							; get PORTD state

	ldi tmp3, 1								; position of LED_1
	sbrs parameters, 4						;
	cbr tmp1, 1								; turn off LED_1
	sbrc parameters, 4						;
	eor tmp1, tmp3							; toggle LED_1

	ldi tmp3, 2								; position of LED_2
	sbrs parameters, 5						;
	cbr tmp1, 2								; turn off LED_2
	sbrc parameters, 5						;
	eor tmp1, tmp3							; toggle LED_2

	out PORTD, tmp1							; update PORTD state

; sound effects -----------------------------
	mov tmp1, parameters					;
	ldi tmp3, 0b11000000					; get effect
	and tmp1, tmp3							;
	breq effect_end							; jump to effect_end if no effect is selected

	cpi tmp1, 192							; check if [11-000000]: vibrato
 	breq vibrato							;
	cpi tmp1, 128							; check if [10-000000]: pitch bend down
	breq pitch_bend_down					;
	cpi tmp1, 64							; check if [01-000000]: pitch bend up
	breq pitch_bend_up						;

vibrato: ; ================================== (13 clock ticks)
	mov tmp1, duration						;
	ldi tmp3, 0b00001100					;
	and tmp1, tmp3							; keep 3rd and 4th duration bits
	tst tmp1								;
	breq vibrato_add1						; if duration = xxxx00xx -> vibrato_add
	cpi tmp1, 12							;
	breq vibrato_add2						; if duration = xxxx11xx -> vibrato_add
	rjmp vibrato_sub						; else -> vibrato_sub
vibrato_add1: ; ------------------------------
	nop										;
	nop										;
vibrato_add2: ; ------------------------------
	nop										;
	adiw phase_delta_h:phase_delta_l, 20	;
	rjmp update_end							;
vibrato_sub: ; ------------------------------
	sbiw phase_delta_h:phase_delta_l, 20	;
	rjmp update_end							;

pitch_bend_down: ; ========================== (11 clock ticks)
	rcall fake_routine						;
	sbiw phase_delta_h:phase_delta_l, 1		;
	rjmp update_end							;

pitch_bend_up: ; ============================ (9 clock ticks)
	nop										;
	nop										;
	nop										;
	nop										;
	nop										;
	adiw phase_delta_h:phase_delta_l, 1		;
	rjmp update_end							;

effect_end: ; =============================== (15 clock ticks)
	rcall fake_routine						;
	rcall fake_routine						;
	nop										;

update_end:	; =============================== (16 clock ticks -- without ret)
	clr XH									; prepare pointer
	mov XL, channel_data					;
	st X+, phase_delta_l					; copy channel's data from register file to SRAM
	st X+, phase_delta_h					;
	st X+, note_ptr_l						;
	st X+, note_ptr_h						;
	st X+, duration							;
	st X+, parameters						;
	st X, volume							;
	ret



; ****************************************************************
; * routine for delay (7 clock ticks -- with call and ret)
; ****************************************************************

fake_routine:
	ret