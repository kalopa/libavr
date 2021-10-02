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
; void _sleep();
;
; Put the processor to sleep until the next interrupt
	.global	_sleep
	.func	_sleep
_sleep:
	sei					; Make sure interrupts are on
	in	r24,MCUCR
	andi	r24,0x0f			; Set sleep mode to IDLE
	ori	r24,0x80			; Enable the sleep system
	out	MCUCR,r24
	sleep					; Do it!
	ret					; Ok, we're back
	.endfunc
;
; Fin
