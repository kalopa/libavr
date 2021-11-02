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
; Send and receive a packet over the RS232 line. The packet format
; is as follows:
;   HH-DD-SS-CC-CK-P1-P2
;   0  1  2  3  4  5  6  7=DONE		rxpacket #1
;   0  8  9 10 11 12 13 14=DONE		rxpacket #2
;
; HH: Header
; DD: Destination
; SS: Source
; CC: Command byte
; CK: Checksum
; P1: Payload byte 1
; P2: Payload byte 2
;
#include <avr/io.h>
;
; void _pkt_in();
;
; Receive a packet over the wire.
	.section .init6,"ax",@progbits
	.global	_pkt_in
	.func	_pkt_in
_pkt_in:
	push	r24		; Save the status register
	in	r24,_SFR_IO_ADDR(SREG)
	push	r24
	push	r25
;
	in	r24,UDR		; Pull the character
	cpi	r24,0xfe	; Header?
	brne	in2		; No, look to see what then.
;
; We have a header byte - find a free packet slot, and set it up.
	sts	rxstate,r1	; In state0, just in case...
	ldi	r25,1
	lds	r24,rxpackets	; Is slot 0 available?
	tst	r24
	breq	in1		; Yes...
	ldi	r25,8
	lds	r24,rxpackets+7	; What about slot 1?
	tst	r24
	brne	in5		; Oops - drop the packet
;
; RX packet0 or 1 is free and available.
in1:	sts	rxstate,r25
	sts	rxesc,r1	; No escape character
	sts	cksum,r1	; Clear the checksum
	rjmp	in5
;
; In state0, we ignore everything except a header byte.
in2:	lds	r25,rxstate	; Are we in state0?
	tst	r25
	breq	in5		; Yes - ignore character
;
; Is this an escape byte?
	cpi	r24,0xff	; Escape byte?
	brne	in3
	ldi	r24,0x80	; Turn on escape char
	sts	rxesc,r24
	rjmp	in5
;
; Ok, it's a regular character - we should save it.
in3:	push	r26
	push	r27
;
	lds	r26,rxesc	; Is this byte escaped?
	or	r24,r26		; Turn on high bit if need be.
	sts	rxesc,r1	; clear the escape.
;
	ldi	r26,lo8(rxpackets) ; Get the base packet addr
	ldi	r27,hi8(rxpackets)
	add	r26,r25		; State is the offset...
	adc	r27,r1
	st	X,r24		; Save the byte...
;
	lds	r26,cksum	; Add to the checksum.
	add	r26,r24
	sts	cksum,r26
;
	inc	r25		; Next state.
	sts	rxstate,r25
;
	cpi	r25,7		; State7? Are we done/
	breq	in6
	cpi	r25,14		; State14? Are we done?
	breq	in6
;
; We're done...
in4:	pop	r27
	pop	r26
in5:	pop	r25		; Restore the status register
	pop	r24
	out	_SFR_IO_ADDR(SREG),r24
	pop	r24
	reti			; Return from interrupt
;
; Packet has been received! Check the checksum, and mark it as ready.
in6:	sts	rxstate,r1
	tst	r26		; Is the checksum OK?
	brne	in4		; Nope, dump the packet.
;
; Packet is good!
	subi	r25,7
	ldi	r26,lo8(rxpackets) ; Get the base packet addr
	ldi	r27,hi8(rxpackets)
	add	r26,r25		; State is the offset...
	adc	r27,r1
	ldi	r25,1		; Give back the buffer.
	st	X,r25		; Set the ready byte.
	rjmp	in4
	.endfunc
;
; void _pkt_out();
;
; Send a packet over the wire.
	.global	_pkt_out
	.func	_pkt_out
_pkt_out:
	push	r24		; Save the status register
	in	r24,_SFR_IO_ADDR(SREG)
	push	r24
	push	r25
;
	lds	r24,txstate	; Are we in state0?
	tst	r24
	brne	out2		; Nope.
;
; State0: We haven't started a transmission, yet.
	ldi	r25,1
	lds	r24,txpackets	; Is slot 0 ready?
	tst	r24
	breq	out1		; Yes, slot0 is ready.
	ldi	r25,8
	lds	r24,txpackets+7	; What about slot 1?
	tst	r24
	breq	out1		; Yes, slot1 is ready.
;
; Nothing to send - why are we here?
	cbi	UCSRB,5		; Disable TX ints
isrout:	pop	r25		; Restore the status register
	pop	r24
	out	_SFR_IO_ADDR(SREG),r24
	pop	r24
	reti			; Return from interrupt
;
; We have a slot - set up the state, and send a header.
out1:	sts	txstate,r25	; Set the state.
	sts	txesc,r1	; Clear the escape.
	ldi	r25,0xfe	; Send a header byte.
	out	UDR,r25		; Transmit it
	rjmp	isrout		; We're done (for now).
;
; In the midst of a transmission.
out2:	push	r26
	push	r27
;
	ldi	r26,lo8(txpackets) ; Get the base packet addr
	ldi	r27,hi8(txpackets)
	add	r26,r24		; State is the offset...
	adc	r27,r1
	ld	r25,X		; Get the transmit byte.
	mov	r24,r25		; Get a test copy.
	andi	r24,0xfe	; Strip the LSB.
	cpi	r24,0xfe	; A special byte?
	brne	out3		; No...
;
; We have a special one - clear the high bit and send an escape.
	andi	r25,0x7f	; Strip high bit.
	st	X,r25
	ldi	r25,0xff	; Send an escape
	out	UDR,r25
	rjmp	out5
;
; Regular character - send it.
out3:	out	UDR,r25		; Transmit the byte.
	lds	r25,txstate	; Increment the state.
	inc	r25
	sts	txstate,r25
	cpi	r25,7		; State7?
	breq	out4		; Yep - do cleanup.
	cpi	r25,14		; State14?
	brne	out5		; No, we're done.
;
; We've sent the whole packet - now what?
out4:	subi	r25,7
	ldi	r26,lo8(txpackets) ; Get the base packet addr
	ldi	r27,hi8(txpackets)
	add	r26,r25		; State is the offset...
	adc	r27,r1
	ldi	r25,1
	st	X,r25		; Release the buffer.
	sts	txstate,r1	; Back to state0
;
out5:	pop	r27
	pop	r26
	rjmp	isrout
	.endfunc
;
; Fin.
