; ****************************************************************
; * flash constants table
; ****************************************************************

deltas:		; phase delta for each note
	; 2nd octave --------- 0
	.db		0x00, 0x85   ; (C)
	.db		0x00, 0x8d   ; (C#)
	.db		0x00, 0x95   ; (D)
	.db		0x00, 0x9e   ; (Eb)
	.db		0x00, 0xa7   ; (E)
	.db		0x00, 0xb1   ; (F)
	.db		0x00, 0xbc   ; (F#)
	.db		0x00, 0xc7   ; (G)
	.db		0x00, 0xd3   ; (G#)
	.db		0x00, 0xdf   ; (A)
	.db		0x00, 0xed   ; (Bb)
	.db		0x00, 0xfb   ; (B)
	; 3rd octave --------- 24
	.db		0x01, 0x0a   ; (C)
	.db		0x01, 0x1a   ; (C#)
	.db		0x01, 0x2a   ; (D)
	.db		0x01, 0x3c   ; (Eb)
	.db		0x01, 0x4f   ; (E)
	.db		0x01, 0x63   ; (F)
	.db		0x01, 0x78   ; (F#)
	.db		0x01, 0x8e   ; (G)
	.db		0x01, 0xa6   ; (G#)
	.db		0x01, 0xbf   ; (A)
	.db		0x01, 0xda   ; (Bb)
	.db		0x01, 0xf6   ; (B)
	; 4th octave --------- 48
	.db		0x02, 0x13	; (C)
	.db		0x02, 0x33	; (C#)
	.db		0x02, 0x55	; (D)
	.db		0x02, 0x78	; (Eb)
	.db		0x02, 0x9e	; (E)
	.db		0x02, 0xc5	; (F)
	.db		0x02, 0xf0	; (F#)
	.db		0x03, 0x1c	; (G)
	.db		0x03, 0x4c	; (G#)
	.db		0x03, 0x7e	; (A)
	.db		0x03, 0xb3	; (Bb)
	.db		0x03, 0xeb	; (B)
	; 5th octave --------- 72
	.db		0x04, 0x27   ; (C)
	.db		0x04, 0x66   ; (C#)
	.db		0x04, 0xa9   ; (D)
	.db		0x04, 0xf0   ; (Eb)
	.db		0x05, 0x3b   ; (E)
	.db		0x05, 0x8b   ; (F)
	.db		0x05, 0xdf   ; (F#)
	.db		0x06, 0x39   ; (G)
	.db		0x06, 0x97   ; (G#)
	.db		0x06, 0xfc   ; (A)
	.db		0x07, 0x66   ; (Bb)
	.db		0x07, 0xd7   ; (B)
	; 6th octave --------- 96
	.db		0x08, 0x4f   ; (C)
	.db		0x08, 0xcd   ; (C#)
	.db		0x09, 0x53   ; (D)
	.db		0x09, 0xe1   ; (Eb)
	.db		0x0a, 0x78   ; (E)
	.db		0x0b, 0x16   ; (F)
	.db		0x0b, 0xbf   ; (F#)
	.db		0x0c, 0x72   ; (G)
	.db		0x0d, 0x2e   ; (G#)
	.db		0x0d, 0xf8   ; (A)
	.db		0x0e, 0xcd   ; (Bb)
	.db		0x0f, 0xae   ; (B)
	; 7th octave --------- 120
	.db		0x10, 0x9c   ; (C)
	.db		0x11, 0x98   ; (C#)
	.db		0x12, 0xa4   ; (D)
	.db		0x13, 0xc1   ; (Eb)
	.db		0x14, 0xed   ; (E)
	.db		0x16, 0x2c   ; (F)
	.db		0x17, 0x7e   ; (F#)
	.db		0x18, 0xe3   ; (G)
	.db		0x1a, 0x5d   ; (G#)
	.db		0x1b, 0xef   ; (A)
	.db		0x1d, 0x98   ; (Bb)
	.db		0x1f, 0x5b   ; (B)

	.db		0x00, 0x00   ; pseudo note 144 (pause)
	.db		0xff, 0xff   ; pseudo note 146 (melody end)

	.db		0x9f, 0xf0	 ; pseudo note 148 (noise 0)
	.db		0x7e, 0xf0   ; pseudo note 150 (noise 1)
	.db		0x6c, 0xf0   ; pseudo note 152 (noise 2)
	.db		0x5a, 0xf0   ; pseudo note 154 (noise 3)
	.db		0x48, 0xf0   ; pseudo note 156 (noise 4)
	.db		0x36, 0xf0   ; pseudo note 158 (noise 5)
	.db		0x24, 0xf0   ; pseudo note 160 (noise 6)
	.db		0x12, 0xf0   ; pseudo note 162 (noise 7)

durations:	;	note duration for each rythm
			;	1/32,	1/16,	1/16*,	1/8,	1/8*,	1/4,	1/4*,	1/2
bpm90:  .db		16,		32,		48,		64,		96,		128,	192,	255
bpm120: .db		12,		24,		36,		48,		72,		96,		144,	192
bpm150: .db 	10,		20,		30,		40,		60,		80,		120,	160
bpm180: .db		8,		16,		24,		32,		48,		64,		96,		128


; music notation specifications:
; ----------------------------------------------------------------
;
; acceptable values for melody rythm:
;				0	->	60bpm
;				8	->	120bpm
;				16	->	150bpm
;				24	->	180bpm
;
; two bytes per note (.db 0x00, 0x00)
;
; 1st byte - 2 upper bits: effect
;			  0 (00-000000): no effect
;			 64 (01-000000): pitch bend up
;			128 (10-000000): pitch bend down
;			192 (11-000000): vibrato
;
; 1st byte - 3 middle bits: other parameters
;			  0 (00-xx0-000): duty cycle = 50% (ch1 & ch2)   ---   ring modulation = 0 (ch3)
;			  8 (00-xx1-000): duty cycle = 75% (ch1 & ch2)   ---   ring modulation = 1 (ch3)
;
;			  0 (00-x0x-000): LED_1 = 0 (all channels)
;			 16 (00-x1x-000): LED_1 = pulsating (all channels)
;
;			  0 (00-0xx-000): LED_2 = 0 (all channels)
;			 32 (00-1xx-000): LED_2 = pulsating (all channels)
;
; 1st byte - 3 lower bits: duration
;			  0 (00000-000): 1/32
;			  1 (00000-001): 1/16
;			  2 (00000-010): 1/16* (3/32)
;			  3 (00000-011): 1/8
;			  4 (00000-100): 1/8* (3/16)
;			  5 (00000-101): 1/4
;			  6 (00000-110): 1/4* (3/8)
;			  7 (00000-111): 1/2
;
; 2nd byte: pointer to a specific note/octave


melody_rythm:
.db 16, 0

ch1_melody:
.db 9, 58, 9, 66, 9, 52, 9, 58, 9, 48, 9, 56, 9, 52, 9, 56, 9, 52, 9, 58, 9, 52, 9, 62, 9, 52, 9, 64, 9, 52, 9, 66
.db 9, 58, 9, 42, 9, 28, 9, 58, 9, 24, 9, 32, 217, 28, 9, 56, 201, 28, 9, 58, 233, 28, 9, 62, 201, 28, 9, 64, 217, 28, 9, 66
.db 9, 58, 9, 42, 9, 28, 9, 58, 9, 24, 9, 32, 217, 52, 9, 56, 201, 52, 9, 58, 233, 52, 9, 62, 201, 52, 9, 64, 217, 52, 9, 66
.db 9, 58, 9, 42, 9, 28, 9, 58, 9, 24, 9, 32, 201, 28, 9, 56, 9, 28, 9, 58, 233, 28, 9, 62, 9, 28, 9, 64, 201, 28, 9, 66
.db 9, 58, 9, 42, 9, 28, 9, 58, 9, 24, 9, 32, 201, 52, 9, 56, 9, 28, 9, 58, 233, 52, 9, 62, 9, 28, 9, 64, 201, 52, 9, 66
.db 201, 28, 68, 4, 4, 144, 8, 58, 8, 66, 8, 52, 8, 58, 8, 48, 8, 56, 8, 52, 8, 56, 8, 52, 8, 58, 8, 52, 8, 62, 8, 52
.db 8, 64, 8, 52, 8, 66, 66, 28, 8, 146

ch2_melody:
ch3_melody:
ch4_melody:
.db 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144
.db 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144
.db 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144
.db 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144, 7, 144
