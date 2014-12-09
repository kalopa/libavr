;
; Copyright (c) 2007, Kalopa Research.  All rights reserved.  This is free
; software; you can redistribute it and/or modify it under the terms of the
; GNU General Public License as published by the Free Software Foundation;
; either version 2, or (at your option) any later version.
;
; It is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
; for more details.
;
; You should have received a copy of the GNU General Public License along
; with this product; see the file COPYING.  If not, write to the Free
; Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;
; THIS SOFTWARE IS PROVIDED BY KALOPA RESEARCH "AS IS" AND ANY EXPRESS OR
; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
; IN NO EVENT SHALL KALOPA RESEARCH BE LIABLE FOR ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
; BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
; USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
; ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; ABSTRACT
;
.include "regvals.inc"
;
; void _sio_in();
;
; Serial I/O input interrupt routine (RX).
	.section .init6,"ax",@progbits
	.global	_sio_in
	.func	_sio_in
_sio_in:
	push	r24					; Save the status register
	in		r24,SREG
	push	r24
	push	r25
	push	r26
	push	r27
;
	in		r26,UDR				; Pull the character
	lds		r24,ihead			; Get head & tail
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
; void _sio_out();
;
; Serial I/O output interrupt routine (TX).
	.global	_sio_out
	.func	_sio_out
_sio_out:
	push	r24					; Save the status register
	in		r24,SREG
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
	out		UDR,r25				; Transmit it
;
	inc		r24					; Increment the tail pointer
	andi	r24,31
	sts		otail,r24
	lds		r25,ohead			; Get the head pointer
	cp		r24,r25				; Buffer empty?
	brne	siol1				; No, continue
	cbi		UCSRB,5				; Yes - disable TX ints
;
; Common return routine from interrupts.
siol1:
	pop		r27
	pop		r26
	pop		r25					; Restore the status register
	pop		r24
	out		SREG,r24
	pop		r24
	reti						; Return from interrupt
	.endfunc
;
; Fin.
