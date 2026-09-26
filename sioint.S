;
; Copyright (c) 2007-26, Kalopa Robotics Limited.  All rights reserved.
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
; Interrupt service routines for serial I/O. Handles RX and TX interrupts
; which are managed using 32-byte ring buffers. If you changet the size of
; the ring buffer, make sure you make the appropriate changes here. Also
; the helper functions to enable and disable the interrupts are located
; here. The BOOTSTRAP option allows entry into bootstrap mode on receipt
; of a CTRL-E followed by a backslash (^E\). One side-effect (bug!) of this
; behaviour is that ^E is swallowed and not placed into the input buffer.
;
#include <avr/io.h>
#include "oldregs.h"
;
; void sio_in();
;
; Serial I/O input interrupt routine (RX).
	.section .init6,"ax",@progbits
	.global	sio_in
	.func	sio_in
sio_in:
	push	r24					; Save the status register
	in		r24,_SFR_IO_ADDR(SREG)
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
#ifdef __AVR_HAVE_JMP_CALL__
	jmp		_bootstrap			; Run the bootstrap code!
#else
	rjmp	_bootstrap			; Run the bootstrap code!
#endif
#endif
;
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
	in		r24,_SFR_IO_ADDR(SREG)
	push	r24
	push	r25
	push	r26
	push	r27
;
; Check that there's something in the buffer.
	lds		r24,otail			; Get the head and tail
	lds		r25,ohead
	cp		r24,r25				; Buffer empty?
	brne	1f
;
; Yes - disable the interrupt and go home.
	rcall	_sio_txintoff
	rjmp	siol1
;
; We have something to send.
1:	ldi		r26,lo8(oring)		; Get the base ring buffer addr
	ldi		r27,hi8(oring)
	add		r26,r24
	adc		r27,r1				; R1 is always zero!!!
	ld		r25,X				; Get the character in the ring
	sts		UDR0,r25			; Transmit it
;
	inc		r24					; Increment the tail pointer
	andi	r24,31
	sts		otail,r24
;
; Common return routine from interrupts.
siol1:
	pop		r27
	pop		r26
	pop		r25					; Restore the status register
	pop		r24
	out		_SFR_IO_ADDR(SREG),r24
	pop		r24
	reti						; Return from interrupt
	.endfunc
;
; void _sio_rxinton();
;
; Enable transmission interrupts.
	.global	_sio_rxinton
	.func	_sio_rxinton
_sio_rxinton:
	lds		r24,UCSR0B			; Enable RX ints
	ori		r24,0x80
	sts		UCSR0B,r24
	ret
	.endfunc
;
; void _sio_rxintoff();
;
; Disable transmission interrupts.
	.global	_sio_rxintoff
	.func	_sio_rxintoff
_sio_rxintoff:
	lds		r24,UCSR0B			; Disable RX ints
	andi	r24,0x7f
	sts		UCSR0B,r24
	ret
	.endfunc
;
; void _sio_txinton();
;
; Enable transmission interrupts.
	.global _sio_txinton
	.func   _sio_txinton
_sio_txinton:
	lds		r24,UCSR0B			; Enable TX ints
	ori		r24,0x20
	sts		UCSR0B,r24
	ret
	.endfunc
;
; void _sio_txintoff();
;
; Disable transmission interrupts.
	.global _sio_txintoff
	.func   _sio_txintoff
_sio_txintoff:
	lds		r24,UCSR0B			; Disable TX ints
	andi	r24,0xdf
	sts		UCSR0B,r24
	ret
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
