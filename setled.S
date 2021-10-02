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
; void _setled(uchar_t);
;
; Set interrupts to specified value.
	.global	_setled
	.func	_setled
_setled:
	tst	r24				; LED on or off?
	breq	sl1
	cbi	PORTC,3				; Turn on the LED
	ret
sl1:	sbi	PORTC,3				; Turn off the LED
	ret
	.endfunc
;
; Fin.
