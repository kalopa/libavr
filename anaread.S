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
; Wait for the conversion to complete and read the result of an A
; to D conversion.
;
#include <avr/io.h>
;
; uint_t _ana_read();
;
; Set interrupts to specified value.
	.global	_ana_read
	.func	_ana_read
_ana_read:
	sbis	ADCSR,4				; Are we done?
	rjmp	_ana_read			; No - busy loop
;
	in	r24,__ADCL__			; Yes - read the result
	in	r25,__ADCH__
	ret
	.endfunc
;
; Fin.
