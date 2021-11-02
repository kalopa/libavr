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
#include <avr/io.h>
;
; void _watchdog();
;
; This will reset the watchdog timer, preventing an automatic reset.
	.global	_watchdog
	.func	_watchdog
_watchdog:
	wdr					; Ping the watchdog timer
	ret
	.endfunc
;
; void _wdenable();
;
; Enable the watchdog timer.
	.global	_wdenable
	.func	_wdenable
_wdenable:
	push	r24
	in	r24,_SFR_IO_ADDR(SREG)			; Save INTE status
	push	r24
;
	cli					; No interrupts!
	wdr					; Clear the watchdog
	ldi	r24,0x1f			; WDCE, WDE, WDP=2048k
	out	WDTCR,r24
	ldi	r24,0x0f			; WDE, WDP=2048k
	out	WDTCR,r24
	wdr
;
	pop	r24
	out	_SFR_IO_ADDR(SREG),r24
	pop	r24
	ret
	.endfunc
;
; Fin
