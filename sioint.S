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
; void sio_in();
;
; Serial I/O input interrupt routine (RX).
	.section .init6,"ax",@progbits
	.global	sio_in
	.func	sio_in
sio_in:
	push	r24					; Save the status register
	in		r24,AVR_STATUS_ADDR
	push	r24
	push	r25
	push	r26
	push	r27
;
	lds		r26,UDR0			; Pull the character
#ifdef BOOTSTRAP
	cpi		r26,5				; Saw CTRL-E?
	brne	1f
	sts		_saw_ctrle,r26		; Set flag to true
	rjmp	siol1				; Ignore the character.
;
1:	lds		r24,_saw_ctrle		; Get flag state
	tst		r24					; Set?
	breq	2f
;
	ldi		r24,0				; Clear the flag
	sts		_saw_ctrle,r24
	cpi		r26,'\\'			; Backslash?
	brne	2f
	jmp		_bootstrap			; Run the bootstrap code!
;
#endif
2:	lds		r24,ihead			; Get head & tail
	lds		r25,itail
	inc		r24
	andi	r24,31
	cp		r24,r25				; Buffer full?
	breq	siol1				; No choice but to drop the character
;
	lds		r24,ihead
	mov		r25,r26
	ldi		r26,lo8(iring)
	ldi		r27,hi8(iring)
	add		r26,r24				; Add the head pointer
	adc		r27,r1				; R1 is always zero!!!
	st		X,r25				; Save the character
	inc		r24
	andi	r24,31
	sts		ihead,r24			; Save the new head pointer
;
	rjmp	siol1				; We're done
	.endfunc
;
; void sio_out();
;
; Serial I/O output interrupt routine (TX).
	.global	sio_out
	.func	sio_out
sio_out:
	push	r24					; Save the status register
	in		r24,AVR_STATUS_ADDR
	push	r24
	push	r25
	push	r26
	push	r27
;
	ldi		r26,lo8(oring)		; Get the base ring buffer addr
	ldi		r27,hi8(oring)
	lds		r24,otail			; Add the tail pointer
	add		r26,r24
	adc		r27,r1				; R1 is always zero!!!
	ld		r25,X				; Get the character in the ring
	sts		UDR0,r25			; Transmit it
;
	inc		r24					; Increment the tail pointer
	andi	r24,31
	sts		otail,r24
	lds		r25,ohead			; Get the head pointer
	cp		r24,r25				; Buffer empty?
	brne	siol1				; No, continue
	lds		r24,UCSR0B	; Disable TX ints
	andi	r24,0xdf
	sts		UCSR0B,r24
;
; Common return routine from interrupts.
siol1:
	pop		r27
	pop		r26
	pop		r25					; Restore the status register
	pop		r24
	out		AVR_STATUS_ADDR,r24
	pop		r24
	reti						; Return from interrupt
	.endfunc
;
; Look for ^E\ in order to enter bootstrap mode.
#ifdef BOOTSTRAP
	.section .bss
_saw_ctrle:
	.zero	1
#endif
;
; Fin.
