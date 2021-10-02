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
	sbi		UCSRB,7				; Enable RX ints
	ret
	.endfunc
;
; void _sio_rxintoff();
;
; Disable transmission interrupts.
	.global	_sio_rxintoff
	.func	_sio_rxintoff
_sio_rxintoff:
	cbi		UCSRB,7				; Disable RX ints
	ret
	.endfunc
;
; void _sio_txinton();
;
; Enable transmission interrupts.
	.global	_sio_txinton
	.func	_sio_txinton
_sio_txinton:
	sbi		UCSRB,5				; Enable TX ints
	ret
	.endfunc
;
; void _sio_txintoff();
;
; Disable transmission interrupts.
	.global	_sio_txintoff
	.func	_sio_txintoff
_sio_txintoff:
	cbi		UCSRB,5				; Disable TX ints
	ret
	.endfunc
;
; Fin.
