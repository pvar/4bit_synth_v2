; ****************************************************************
; * clear all music-related data
; ****************************************************************

init_music_data:
	clr tmp1								; clear all channels' data
	ldi tmp2, 38							;
	ldi XL, 0x62							;
	ldi XH, 0								;
clear_loop:									;
	st X+, tmp1								;
	dec tmp2								;
	brne clear_loop							;

	ldi tmp1, 1								; set initial duration
	sts ch1_duration, tmp1					;
	sts ch2_duration, tmp1					;
	sts ch3_duration, tmp1					;
	sts ch4_duration, tmp1					;

	ldi tmp4, high(ch1_melody*2)			; initialize note pointers
	ldi tmp3, low(ch1_melody*2)				;
	sts ch1_note_ptr_h, tmp4				;
	sts ch1_note_ptr_l, tmp3				;

	ldi tmp4, high(ch2_melody*2)			;
	ldi tmp3, low(ch2_melody*2)				;
	sts ch2_note_ptr_h, tmp4				;
	sts ch2_note_ptr_l, tmp3				;

	ldi tmp4, high(ch3_melody*2)			;
	ldi tmp3, low(ch3_melody*2)				;
	sts ch3_note_ptr_h, tmp4				;
	sts ch3_note_ptr_l, tmp3				;

	ldi tmp4, high(ch4_melody*2)			;
	ldi tmp3, low(ch4_melody*2)				;
	sts ch4_note_ptr_h, tmp4				;
	sts ch4_note_ptr_l, tmp3				;

	ldi ZH, high(melody_rythm*2)			;
	ldi ZL, low(melody_rythm*2)				;
	lpm										;
	mov rythm, r0							; get melody rythm
	ret



; ****************************************************************
; * waveform generation (calculate and output new samples)
; ****************************************************************

waveform:
	clr sample_acc
sample_ch1: ; ------------------------------- square (28 clock ticks)
	lds tmp1, ch1_phase_accum_l				; load phase_accum
	lds tmp2, ch1_phase_accum_h				;
	lds tmp3, ch1_phase_delta_l				; load phase_delta
	lds tmp4, ch1_phase_delta_h				;
	add tmp1, tmp3							; add phase_delta to phase_accumulator
	adc tmp2, tmp4							;

	brcc no_clr1							;
	clr tmp1								; clear low byte on accumulator overflow (the other is already cleared ;-)
no_clr1:
	sts ch1_phase_accum_l, tmp1				; save phase_accum
	sts ch1_phase_accum_h, tmp2				;

	lds parameters, ch1_parameters			; load effect and extra params
	ldi tmp4, 0b10000000					;
	sbrc parameters, 3						; select duty cycle
	ldi tmp4, 0b11000000					;

	cp tmp2, tmp4							; compare with duty cycle
	brcs keep_low1							;
	lds sample, ch1_volume					;
	rjmp end_ch1							;
keep_low1:
	clr sample
	nop
	nop
end_ch1:
	add sample_acc, sample 					; add sample to total

sample_ch2: ; ------------------------------- square (28 clock ticks)
	lds tmp1, ch2_phase_accum_l				; load phase_accum
	lds tmp2, ch2_phase_accum_h				;
	lds tmp3, ch2_phase_delta_l				; load phase_delta
	lds tmp4, ch2_phase_delta_h				;
	add tmp1, tmp3							; add phase_delta to phase_accumulator
	adc tmp2, tmp4							;

	brcc no_clr2							;
	clr tmp1								; clear low byte on accumulator overflow (the other is already cleared ;-)
no_clr2:
	sts ch2_phase_accum_l, tmp1				; save phase_accum
	sts ch2_phase_accum_h, tmp2				;

	lds parameters, ch2_parameters			; load effect and extra params
	ldi tmp4, 0b10000000					;
	sbrc parameters, 3						; select duty cycle
	ldi tmp4, 0b11000000					;

	cp tmp2, tmp4							; compare with duty cycle
	brcs keep_low2							;
	lds sample, ch1_volume					;
	rjmp end_ch2							;
keep_low2:
	clr sample
	nop
	nop
end_ch2:
	add sample_acc, sample 					; add sample to total

sample_ch3: ; ------------------------------- triangle (29 clock ticks)
	lds tmp1, ch3_phase_accum_l				; load phase_accum
	lds tmp2, ch3_phase_accum_h				;
	lds tmp3, ch3_phase_delta_l				; load phase_delta
	lds tmp4, ch3_phase_delta_h				;
	add tmp1, tmp3							; add phase_delta to phase_accumulator
	adc tmp2, tmp4							;

	brcc no_clr3							;
	clr tmp1								; clear low byte on accumulator overflow (the other is already cleared ;-)
no_clr3:
	sts ch3_phase_accum_l, tmp1				; save phase_accum
	sts ch3_phase_accum_h, tmp2				;

	mov sample, tmp2						; get high byte of accumulator
	swap sample								; swap nibbles
	andi sample, 0b00000111					; keep 3LSBs of transposed high nibble
	lsl sample								; shift left
	ldi tmp3, 0b00001110					; prepare mask according to msb of high nibble of high byte of accumulator
	sbrs tmp2, 7							;
	ldi tmp3, 0b00000001					;
	eor sample, tmp3						; exclusive OR with mask to "center" values around 7

	lds parameters, ch3_parameters			; load effect and extra params
	sbrc parameters, 3						; check if ring modulation is enabled
	eor sample, ring_osc					;
	add sample_acc, sample 					; add sample to total

sample_ch4: ; ------------------------------- noise (25 clock ticks)
	lds tmp1, ch4_phase_accum_l				; load phase_accum
	lds tmp2, ch4_phase_accum_h				;
	lds tmp3, ch4_phase_delta_l				; load phase_delta
	lds tmp4, ch4_phase_delta_h				;
	add tmp1, tmp3							; add phase_delta to phase_accumulator
	adc tmp2, tmp4							;
noise:
	brcc skip_lfsr							; if accumulator overflows, compute new sample
	ldi tmp3, 2								; prepare LFSR tap
	lsl lfsr_l								; shift LFSR registers
	rol lfsr_h								;
	brvc skip_xor							;
	eor lfsr_l, tmp3						; exclusive OR with tap
skip_xor:
	mov sample, lfsr_l						; get sample from LFSR low byte
	andi sample, 0b00000111					; mask-out all but 3LSBs
	rjmp exit_lfsr
skip_lfsr:
	rcall fake_routine
	nop
exit_lfsr:
	sts ch4_phase_accum_l, tmp1				; save phase_accum
	sts ch4_phase_accum_h, tmp2				;
	add sample_acc, sample 					; add sample to total

; -------------------------------------------
	out PORTB, sample_acc					; output sum of samples

	rcall ring								; 13 (with call and ret)
	ret



; ****************************************************************
; * play loop (generate samples & update channels)
; ****************************************************************

play:
	rcall init_music_data

play_loop:
	ldi loop_cnt, 164

sample_loop: ; ------------------------------ (164 * 248 clock cycles)
	rcall waveform							; 125 clock ticks (with call and ret)
	ldi tmp3, 37							; 1 clock tick
	rcall delay								; 3*37+7=118 clock ticks (with call and ret)
	nop										; 1 clock tick
	dec loop_cnt							; 1 clock tick
	brne sample_loop						; 2|1 clock ticks
	nop										;   1 clock tick

; ------------------------------------------- (248 clock cycles)
	rcall waveform							; 125 clock ticks (with call and ret)
	ldi channel_data, ch1_data				; 1 clock tick
	rcall update							; 90 clock ticks (with call and ret)
	ldi tmp3, 8								; 1 clock tick
	rcall delay								; 3*8+7=31 clock ticks (with call and ret)

; ------------------------------------------- (248 clock cycles)
	rcall waveform							; 125 clock ticks (with call and ret)
	ldi channel_data, ch2_data				; 1 clock tick
	rcall update							; 90 clock ticks (with call and ret)
	ldi tmp3, 8								; 1 clock tick
	rcall delay								; 3*8+7=31 clock ticks (with call and ret)

; ------------------------------------------- (248 clock cycles)
	rcall waveform							; 125 clock ticks (with call and ret)
	ldi channel_data, ch3_data				; 1 clock tick
	rcall update							; 90 clock ticks (with call and ret)
	ldi tmp3, 8								; 1 clock tick
	rcall delay								; 3*8+7=31 clock ticks (with call and ret)

; ------------------------------------------- (242 clock cycles)
	rcall waveform							; 125 clock ticks (with call and ret)
	ldi channel_data, ch4_data				; 1 clock tick
	rcall update							; 90 clock ticks (with call and ret)
	ldi tmp3, 6								; 1 clock tick
	rcall delay								; 3*6+7=25 clock ticks (with call and ret)

; ------------------------------------------- (6 clock cycles --when music keeps playing)
	lds tmp3, ch1_phase_delta_h				;
	cpi tmp3, 0xff							;
	brne play_loop							; if high byte of phase delta != 0xff : keep playing
stop:
	ret



; ****************************************************************
; * small delay: 3 * tmp3
; ****************************************************************

delay:
	dec tmp3
	brne delay
	nop
	ret



; ****************************************************************
; * update ring modulator oscillator
; ****************************************************************

; ring_freq = smpl_freq / ring_cnt

ring: ; ================================= (6 clock ticks)
	dec ring_cnt						;
	brne ring_end						; decrease division-counter

	ldi tmp1, 16						;
	mov ring_cnt, tmp1					; reset division-counter

	ldi tmp1, 15						;
	eor ring_osc, tmp1					; toggle ring oscillator
	ret
ring_end:
	nop
	nop
	nop
	ret
