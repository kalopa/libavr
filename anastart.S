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
; Start an Analog to Digital conversion.
;
#include <avr/io.h>
;
; void _ana_start(uchar_t);
;
; Set interrupts to specified value.
	.global	_ana_start
	.func	_ana_start
_ana_start:
	sts	ADMUX,r24			; Set the multiplexors
	nop					; Breathe
	nop
	ldi	r24,0xd3			; ADEN, ADSC, ADPS=/128
	out	ADCSR,r24
	ret
	.endfunc
;
; Fin.
