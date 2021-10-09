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
; void _sio_rxinton();
;
; Enable transmission interrupts.
	.global	_sio_rxinton
	.func	_sio_rxinton
_sio_rxinton:
	lds		r24,UCSR0B			; Disable RX ints
	ori		r24,0x80
	sts		UCSR0B,r24
	ret
	.endfunc
;
; void _sio_rxintoff();
;
; Disable transmission interrupts.
	.global	_sio_rxintoff
	.func	_sio_rxintoff
_sio_rxintoff:
	lds		r24,UCSR0B			; Disable RX ints
	andi	r24,0x7f
	sts		UCSR0B,r24
	ret
	.endfunc
;
; void _sio_txinton();
;
; Enable transmission interrupts.
	.global _sio_txinton
	.func   _sio_txinton
_sio_txinton:
	lds		r24,UCSR0B			; Enable TX ints
	ori		r24,0x20
	sts		UCSR0B,r24
	ret
	.endfunc
;
; void _sio_txintoff();
;
; Disable transmission interrupts.
	.global _sio_txintoff
	.func   _sio_txintoff
_sio_txintoff:
	lds		r24,UCSR0B			; Disable TX ints
	andi	r24,0xdf
	sts		UCSR0B,r24
	ret
	.endfunc
;
; Fin.
