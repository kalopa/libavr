;
; Copyright (c) 2007-26, Kalopa Robotics Limited.  All rights reserved.
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
; void _sleep();
;
; Put the processor to sleep until the next interrupt
	.global	_sleep
	.func	_sleep
_sleep:
	sei					; Make sure interrupts are on
#if defined(__AVR_XMEGA__)
;
; New ATTiny-style architectures...
;
	ldi	r24,SLPCTRL_SEN_bm		; SEN=1, SMODE=IDLE(0) -> 0x01
	sts	SLPCTRL_CTRLA,r24
	sleep					; Night, night!
	ldi	r24,0
	sts	SLPCTRL_CTRLA,r24		; Clear sleep-enable
#else
;
; Older ATmega-style architectures
;
#if defined(__AVR_ATmega8__)
;
; ATmega8: SE + SM bits are in MCUCR, no SMCR
	in	r24,_SFR_IO_ADDR(MCUCR)
	andi	r24,0x0f			; Clear SE + SM2:0
	ori	r24,(1 << SE)			; SE=1, SM=000 (IDLE)
	out	_SFR_IO_ADDR(MCUCR),r24
	sleep
	in	r24,_SFR_IO_ADDR(MCUCR)
	andi	r24,~(1 << SE)			; Clear SE
	out	_SFR_IO_ADDR(MCUCR),r24
#else
;
; ATmega168/328/328P: dedicated SMCR, SM2:0=000 => IDLE
	ldi	r24,(1 << SE)			; = 0x01
	out	_SFR_IO_ADDR(SMCR),r24
	sleep
	ldi	r24,0
	out	_SFR_IO_ADDR(SMCR),r24
#endif
#endif
	ret					; Ok, we're back
	.endfunc
;
; Fin
