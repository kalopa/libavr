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
; void _wreeprom(uint_t, uchar_t);
;
; Write the specified value to the specified EEPROM location
	.global	_wreeprom
	.func	_wreeprom
_wreeprom:
	in	r23,SREG			; Disable interrupts
	cli
wre1:	sbic	EECR,1				; Are we still writing?
	rjmp	wre1				; Yeah, try again

	out	EEARH,r25			; Set up the address
	out	EEARL,r24
	out	EEDR,r22			; Set up the data
	sbi	EECR,2				; Enable the WRITE circuit
	sbi	EECR,1

	out	SREG,r23			; Restore interrupts
	ret
	.endfunc
;
; Fin
