;
; Copyright (c) 2007-21, Kalopa Robotics Limited.  All rights reserved.
;
; This is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2, or (at your option)
; any later version.  It is distributed in the hope that it will be
; useful, but WITHOUT ANY WARRANTY; without even the implied warranty
; of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this product; see the file COPYING.  If not, write to the
; Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;
; ABSTRACT
;
#include <avr/io.h>
;
; void _reset();
;
; To begin, initialize the stack frame, configure the timers and
; I/O pins, as well as the serial port (if fitted), enable interrupts,
; and start working.  The main loop here does several things.  The
; key task is to measure the windmill rotational velocity and try
; to keep it within bounds by altering the pulse width of the output.
	.text
	.section .init0,"ax",@progbits
	.global	_reset
	.func	_reset
_reset:
	cli
	clr		r1
	out		_SFR_IO_ADDR(SREG),r1
	ldi		r16,lo8(RAMEND)				; Set up the stack pointer
	ldi		r17,hi8(RAMEND)
	out		_SFR_IO_ADDR(SPH),r17
	out		_SFR_IO_ADDR(SPL),r16
	call	_ioinit						; Set up the I/O ports
;
; Initialize BSS and data memory.
	ldi		r17,hi8(__data_end)			; End of data block
	ldi		r26,lo8(__data_start)		; X = start od data
	ldi		r27,hi8(__data_start)
	ldi		r30,lo8(__data_load_start)	; Z = program memory
	ldi		r31,hi8(__data_load_start)
	rjmp	2f
1:	lpm									; Fetch a byte from prog mem
	adiw	r30,1						; Increment Z
	st		x+,r0						; Save in [X]
2:	cpi		r26,lo8(__data_end)			; We done yet?
	cpc		r27,r17
	brne	1b						; No, copy some more
	ldi		r17,hi8(__bss_end)			; Point to end of memory
	rjmp	4f
3:	st		x+,r1						; Clear memory
4:	cpi		r26,lo8(__bss_end)			; We done yet?
	cpc		r27,r17
	brne	3b						; No, keep trucking
;
; We're ready for prime time - call the C code.
	call	main						; Call the main routine
	rjmp	_reset
	.endfunc
;
	.section .init4,"ax",@progbits
;
; Some useful (low level) variables...
	.weak	__heap_end
	.weak	__stack
	.set	__heap_end,0
;
; Fin
