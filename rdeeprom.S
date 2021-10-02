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
.include "macros.inc"
;
; uchar_t _rdeeprom(uint_t);
;
; Get the current value from the specified EEPROM location
	.global	_rdeeprom
	.func	_rdeeprom
_rdeeprom:
	in	r22,SREG			; Disable interrupts
	cli
rde1:	sbic	EECR,1				; Are we still writing???
	rjmp	rde1				; Yeah, try again

	out	EEARH,r25			; Set up the address
	out	EEARL,r24
	sbi	EECR,0				; Enable the EEPROM read
	in	r24,EEDR			; Read the byte

	out	SREG,r22			; Restore interrupts
	clr	r25				; No high byte
	ret
	.endfunc
;
; Fin
