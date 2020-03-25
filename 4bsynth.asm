; *********************************************************************************************************************************
; programming	: pvar a.k.a. spir@l evolut10n
; started		: 01-06-2012
; completed		: 
;
;
; *********************************************************************************************************************************

; ****************************************************************
; * fundamental assembler directives
; ****************************************************************

.include "2313def.inc"

.equ ch1_data = 0x62						; channel 1 data
.equ ch1_phase_delta_l = 0x62				;
.equ ch1_phase_delta_h = 0x63				;
.equ ch1_note_ptr_l = 0x64					;
.equ ch1_note_ptr_h = 0x65					;
.equ ch1_duration = 0x66					;
.equ ch1_parameters = 0x67					;
.equ ch1_volume = 0x68						;
.equ ch1_phase_accum_l = 0x69				;
.equ ch1_phase_accum_h = 0x6a				;

.equ ch2_data = 0x6b						; channel 2 data
.equ ch2_phase_delta_l = 0x6b				;
.equ ch2_phase_delta_h = 0x6c				;
.equ ch2_note_ptr_l = 0x6d					;
.equ ch2_note_ptr_h = 0x6e					;
.equ ch2_duration = 0x6f					;
.equ ch2_parameters = 0x70					;
.equ ch2_volume = 0x71						;
.equ ch2_phase_accum_l = 0x72				;
.equ ch2_phase_accum_h = 0x73				;

.equ ch3_data = 0x74						; channel 3 data
.equ ch3_phase_delta_l = 0x74				;
.equ ch3_phase_delta_h = 0x75				;
.equ ch3_note_ptr_l = 0x76					;
.equ ch3_note_ptr_h = 0x77					;
.equ ch3_duration = 0x78					;
.equ ch3_parameters = 0x79					;
.equ ch3_volume = 0x7a						;
.equ ch3_phase_accum_l = 0x7b				;
.equ ch3_phase_accum_h = 0x7c				;

.equ ch4_data = 0x7d						; channel 4 data
.equ ch4_phase_delta_l = 0x7d				;
.equ ch4_phase_delta_h = 0x7e				;
.equ ch4_note_ptr_l = 0x7f					;
.equ ch4_note_ptr_h = 0x80					;
.equ ch4_duration = 0x81					;
.equ ch4_parameters = 0x82					;
.equ ch4_volume = 0x83						;
.equ ch4_phase_accum_l = 0x84				;
.equ ch4_phase_accum_h = 0x85				;

.def channel_data = r23						; channel data (used in update-routine)
.def phase_delta_l = r24					;
.def phase_delta_h = r25					;
.def phase_accum_l = r1						;
.def phase_accum_h = r2						;
.def note_ptr_l = r3						;
.def note_ptr_h = r4						;
.def duration = r5							;
.def parameters = r6						;
.def volume = r7							;
.def duty_cycle = r15						;

.def lfsr_l = r13							; registers for LFSR (used by channel 4 - noise)
.def lfsr_h = r14							;

.def sample = r17							; single sample
.def sample_acc = r16						; sample accumulator

.def loop_cnt = r18							; loop counter in play routine

.def tmp1 = r19								; scratch registers
.def tmp2 = r20								;
.def tmp3 = r21								;
.def tmp4 = r22								;

.def ring_osc = r11							; oscillator for ring modulation
.def ring_cnt = r12							; samples counter until ring_osc update

.def rythm = r10							; offset to "durations" table

;unused r8
;unused r9
;unused r26 ; XL
;unused r27 ; XH
;unused r28 ; YL
;unused r29 ; YH
;unused r30 ; ZL
;unused r31 ; ZH

; ****************************************************************
; * code segment initialization
; ****************************************************************

.cseg
.org 0
	rjmp mcu_init

.include "fade.asm"
.include "play.asm"
.include "update.asm"
.include "data.asm"



; ****************************************************************
; * microcontroller initialization
; ****************************************************************

mcu_init:
	ldi tmp3, $df							; stack space init
	out SPL, tmp3							; Stack Pointer Low byte

	ldi tmp3, 0b10000000					;
	out ACSR, tmp3							; disable analog comparator

	ldi tmp3, 0b00111111					;
	out DDRB, tmp3							; waveform (sample) pins are outputs
	ldi tmp3, 0b11000000					;
	out PORTB, tmp3							; enable pull-up resistors on input pins

	ldi tmp3, 0b00010011					;
	out DDRD, tmp3							; LED pins (PD0, PD1 and PD4) are outputs
	ldi tmp3, 0b11101100					;
	out PORTD, tmp3							; enable pull-up resistors on input pins



; ****************************************************************
; * main program loop
; ****************************************************************

main_loop:
	rcall dimming_cycle

	in tmp3, PIND							; read input pins
	andi tmp3, 0b00100000					; isolate button pin
	brne main_loop							; if not pressed, stay in loop

	cbi PORTD, 4							; else, turn LED off and call play routine
	rcall play								;

	rjmp main_loop							; restart main-loop, when play routine ends
