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
	.section .init2,"ax",@progbits
	cli
	clr	r1
	out	SREG,r1
	ldi	r16,hi8(RAMEND)			; Set up the stack pointer
	out	SPH,r16
	ldi	r16,lo8(RAMEND)
	out	SPL,r16
	rcall	_ioinit				; Set up the I/O ports
;
; Initialize BSS and data memory.
	ldi	r17,hi8(__data_end)		; End of data block
	ldi	r26,lo8(__data_start)		; X = start od data
	ldi	r27,hi8(__data_start)
	ldi	r30,lo8(__data_load_start)	; Z = program memory
	ldi	r31,hi8(__data_load_start)
	rjmp	bssl2

bssl1:	lpm					; Fetch a byte from prog mem
	adiw	r30,1				; Increment Z
	st	x+,r0				; Save in [X]
bssl2:	cpi	r26,lo8(__data_end)		; We done yet?
	cpc	r27,r17
	brne	bssl1				; No, copy some more

	clr	r1				; Fill with zero
	ldi	r17,hi8(__bss_end)		; Point to end of memory
	rjmp	bssl4

bssl3:	st	x+,r1				; Clear memory
bssl4:	cpi	r26,lo8(__bss_end)		; We done yet
	cpc	r27,r17
	brne	bssl3				; No, keep trucking
;
; We're ready for prime time!  Turn on interrupts and call the C code.
	rcall	main				; Call the main routine
	rjmp	_reset
	.endfunc
;
	.section .init4,"ax",@progbits
;
; Some useful (low level) variables...
	.weak	__heap_end
	.weak	__stack
	.set	__heap_end,0
	.set	__stack,RAMEND
;
; Fin
