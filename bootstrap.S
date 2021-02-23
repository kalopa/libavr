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
; This file contains the bootstrap code for reprogramming the AVR
; firmware.  It is invoked by calling _bootstrap from the main code.
;
; The bootstrap command set is fairly primitive (we only have 256
; words to get it done).  All commands begin with an at-sign ('@').
; If the next character is an 'R', then do a reset.  Otherwise, we
; expect exactly four hex characters.  After this, we get one of
; ':', '?' or 'E'.  Colon is used to program the flash memory, '?'
; is used to read flash memory and 'E' is used to erase it.  If we
; are programming memory, then the ':' character is followed by 64
; bytes (one page) of program data.  At the end of this is a 'Z'
; character.  Any deviation from this sequence will cause the
; bootstrap to ignore the command.  The '?' command will result in
; 64 bytes of data from flash memory to be echoed back, followed
; by a CRLF sequence.  The 'E' command will cause the specified
; page to be erased.
;
; The following is an example of some bootstrap commands:
; Reset:
; @R
;
; Dump 64 bytes of flash memory:
; @xxxx?
;
; Erase a page of flash memory:
; @xxxxX
;
; Program a page of flash memory:
; @xxxx:nnnnnn....(64 bytes of data)...nnZ
;
; Remember to erase each page before programming it.
;
; Register usage is as follows:
; r14,r15:	val
; r16:		ch
; r17		state
; r18,r19:	aptr
;
.include "atmega8.inc"
;
; Life begins here...
;
; void _bootstrap();
;
; To begin, initialize the stack frame, then start pulling bytes
; from the serial port.
	.text
	.section .bstrap0,"ax",@progbits
	.global	_bootstrap
	.func	_rbootstrap
_bootstrap:
	clr	r1
	out	SREG,r1
	ldi	r16,hi8(RAMEND)			; Set up the stack pointer
	out	SPH,r16
	ldi	r16,lo8(RAMEND)
	out	SPL,r16
;
again:	clr	r14				; val = 0;
	clr	r15
	clr	r17				; state = 0;
bsloop:	mov	r24,r17
	rcall	puth2
	ldi	r24,'>'
	rcall	putch
	rcall	fetch				; Retrieve a character
	mov	r16,r24				; Save it in ch
	tst	r17				; state == 0??
	brne	dobssw				; No, go handle the char
;
; In the zero state, wait for an '@'.
bs2:	cpi	r24,'@'				; Is it an @?
	brne	again				; No, don't want it
;
	ldi	r17,1				; state = 1;
	rjmp	bsloop				; Start again.
;
dobssw:	clr	r25				; Make switch jump table
	clr	r26
	clr	r27
	movw	r30,r24				; Save the address
	sbiw	r30,'0'				; Subtract '0'
	cpi	r30,55				; We still in the game?
	cpc	r31,r25
	brsh	again				; Nope.
	subi	r30,lo8(-(gs(swtab)))		; Add the switch table
	sbci	r31,hi8(-(gs(swtab)))
	ijmp					; Do the 'case' statement
;
; We're done - now deal with each of the switch cases...
;
; Deal with a numeric digit ('0' -> '9')
bsnum:	swap	r14				; val <<= 4;
	swap	r15
	ldi	r21,0xf0
	and	r15,r21
	eor	r15,r14
	and	r14,r21
	eor	r15,r14
	clr	r21
	add	r14,r16				; val += ch;
	adc	r15,r21
	ldi	r24,lo8(-48)			; val -= '0';
	ldi	r25,hi8(-48)
	add	r14,r24
	adc	r15,r25
	subi	r17,lo8(-(1))			; state++;
;
; Are we OK to stuff the character?
cstuff:	cpi	r17,7				; Need to be in state7 or better
	brlo	bsloop				; No, don't do it.
	mov	r24,r17				; Are we even?
	andi	r24,3
	cpi	r24,2
	brne	bsloop
	ldi	r24,'['
	rcall	putch
	mov	r24,r29
	rcall	puth2
	mov	r24,r28
	rcall	puth2
	ldi	r24,'='
	rcall	putch
	mov	r24,r15
	rcall	puth2
	mov	r24,r14
	rcall	puth2
	ldi	r24,']'
	rcall	putch
	movw	r30,r28				; Get the page address
	movw	r0,r14				; Fetch the word
	ldi	r24,0x01			; SPMEN
	rcall	dospm				; Burn the word!
	adiw	r28,2
	clr	r14
	clr	r15
	rjmp	bsloop				; Go again...
;
; We received a ':' which is an address delimiter
colon:	cpi	r17,5				; State 5?
	brne	a2				; Nope.
	movw	r28,r14				; aptr = val
	ldi	r17,6				; state = 6;
	rjmp	bsloop
;
; Do a page erase...
erase:	cpi	r17,5				; state == 5?
	brne	a2				; Nope.
	movw	r30,r14				; Z = val
	ldi	r24,0x03			; PGERS|SPMEN
	rcall	dospm
	ldi	r24,0x11			; RWWSRE|SPMEN
	rcall	dospm
	rjmp	again
;
; We received a '?' which means dump a block of memory to the RS232 port
quest:	cpi	r17,5				; State 5?
	brne	a2				; Nope.
	movw	r30,r14				; aptr = val;
;
	mov	r24,r31
	rcall	puth2
	mov	r24,r30
	rcall	puth2
	ldi	r24,':'
	rcall	putch
;
	clr	r17				; Clear the counter
ql1:	lpm	r24,Z+				; Read a byte from flash
	rcall	puth2
	subi	r17,lo8(-(1))			; Increment loop
	cpi	r17,PAGESIZEB			; Done?
	brne	ql1				; No, get the next byte
;
	ldi	r24,'\n'			; Output a linefeed
	rcall	putch
a2:	rjmp	again
;
; Received an upper-case hex character.
uchex:	swap	r14				; val <<= 4;
	swap	r15
	ldi	r24,0xf0
	and	r15,r24
	eor	r15,r14
	and	r14,r24
	eor	r15,r14
	add	r14,r18				; val += ch;
	adc	r15,r1
	ldi	r24,lo8(-55)			; val -= 55;
	ldi	r25,hi8(-55)
	rjmp	ulhex
;
; Received a lower-case hex character.
lchex:	swap	r14				; val <<= 4;
	swap	r15
	ldi	r25,0xf0
	and	r15,r25
	eor	r15,r14
	and	r14,r25
	eor	r15,r14
	add	r14,r18				; val += ch;
	adc	r15,r1
	ldi	r24,lo8(-87)			; val -= 87;
;
ulhex:	add	r14,r24
	adc	r15,r25
	subi	r17,lo8(-(1))
	rjmp	cstuff
;
; Do a 'restart'...
dorst:	cpi	r17,1				; state == 1?
	breq	dr1
	rjmp	again				; Nope.  Ignore it.
dr1:	rjmp	_reset
;
; Program a page of memory
doprog:	cpi	r17,134				; state == 134?
	breq	dp1
	rjmp	again				; No, reset instead
dp1:	subi	r28,lo8(PAGESIZEB)		; Back to start of page
	sbci	r29,hi8(PAGESIZEB)
	movw	r30,r28				; Z = aptr
	ldi	r24,0x05			; PGWRT|SPMEN
	rcall	dospm
	ldi	r24,0x11			; RWWSRE|SPMEN
	rcall	dospm
;
dp2:	in	r0,SPMCR			; Check the RWW is ready.
	sbrs	r0,6				; RWWSB is still set?
	rjmp	again				; OK, we're good
	ldi	r24,0x11			; RWWSRE|SPMEN
	rcall	dospm
	rjmp	dp2				; Try again...
	.endfunc
;
; Do an SPM command...
	.section .bstrap0,"ax",@progbits
	.func	dospm
dospm:	in	r0,SPMCR			; Get the SPM status register
	sbrc	r0,0				; SPMEN set?
	rjmp	dospm				; No, keep waiting...
spmw:	sbic	EECR,1				; EEWE clear?
	rjmp	spmw				; No, keep waiting
	out	SPMCR,r24			; Set the SPM control register
	spm					; DO IT, BABY!
	ret
	.endfunc
;
; Output a hex byte to the serial port.
	.section .bstrap0,"ax",@progbits
	.func	puth2
puth2:	mov	r4,r24				; Save the byte
	swap	r24				; Get the high half
	rcall	puth1				; Output it via puth1
	mov	r24,r4				; Restore the byte
	.endfunc				; Fall through to puth1...
;
; Output a hex nybble to the serial port.
	.section .bstrap0,"ax",@progbits
	.func	puth1
puth1:	andi	r24,0x0f			; Only want lower 4 bits
	cpi	r24,10				; Is it 'a' to 'f'?
	brlo	ph2				; No...
	subi	r24,-39				; Yes, adjust
ph2:	subi	r24,-48				; Convert to ASCII
	.endfunc				; Fall through to putch...
;
; Output a charater to the serial port.
	.section .bstrap0,"ax",@progbits
	.func	putch
putch:	cpi	r24,'\n'			; Linefeed?
	brne	pc1				; No, it's OK, just do it.
	ldi	r24,'\r'
	rcall	putch				; Output a CR
	ldi	r24,'\n'			; Now output the linefeed
;
pc1:	sbis	UCSRA,5				; Loop until buffer is empty
	rjmp	pc1
	out	UDR,r24				; Output the character
	ret
	.endfunc
;
; Fetch a character from the serial port.
	.global	fetch
	.section .bstrap0,"ax",@progbits
	.func	fetch
fetch:	sbis	UCSRA,7				; Loop until a char received
	rjmp	fetch
	in	r24,UDR				; Pull in the character
	andi	r24,0x7f			; Strip parity
	ret
	.endfunc
;
; The following is a switch-table, which implements a C case statement.
	.p2align 1
swtab:	rjmp	bsnum				; '0'
	rjmp	bsnum				; '1'
	rjmp	bsnum				; '2'
	rjmp	bsnum				; '3'
	rjmp	bsnum				; '4'
	rjmp	bsnum				; '5'
	rjmp	bsnum				; '6'
	rjmp	bsnum				; '7'
	rjmp	bsnum				; '8'
	rjmp	bsnum				; '9'
	rjmp	colon				; ':'
	rjmp	again				; ';'
	rjmp	again				; '<'
	rjmp	again				; '='
	rjmp	again				; '>'
	rjmp	quest				; '?'
	rjmp	again				; '@'
	rjmp	uchex				; 'A'
	rjmp	uchex				; 'B'
	rjmp	uchex				; 'C'
	rjmp	uchex				; 'D'
	rjmp	uchex				; 'E'
	rjmp	uchex				; 'F'
	rjmp	again				; 'G'
	rjmp	again				; 'H'
	rjmp	again				; 'I'
	rjmp	again				; 'J'
	rjmp	again				; 'K'
	rjmp	again				; 'L'
	rjmp	again				; 'M'
	rjmp	again				; 'N'
	rjmp	again				; 'O'
	rjmp	again				; 'P'
	rjmp	again				; 'Q'
	rjmp	dorst				; 'R'
	rjmp	again				; 'S'
	rjmp	again				; 'T'
	rjmp	again				; 'U'
	rjmp	again				; 'V'
	rjmp	again				; 'W'
	rjmp	erase				; 'X'
	rjmp	again				; 'Y'
	rjmp	doprog				; 'Z'
	rjmp	again				; '['
	rjmp	again				; '\\'
	rjmp	again				; ']'
	rjmp	again				; '^'
	rjmp	again				; '_'
	rjmp	again				; '`'
	rjmp	lchex				; 'a'
	rjmp	lchex				; 'b'
	rjmp	lchex				; 'c'
	rjmp	lchex				; 'd'
	rjmp	lchex				; 'e'
	rjmp	lchex				; 'f'
;
; Fin.
