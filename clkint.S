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
; void _clk_int();
;
; Clock timer tick. Just call the main C routine.
	.section .init6,"ax",@progbits
	.global	_clk_int
	.func	_clk_int
_clk_int:
	push	r24					; Save the status register
	in		r24,SREG
	push	r24
	push	r25					; Save the working regs
;
	push	r18
	push	r19
	push	r26					; Save the temporary regs
	push	r27					; Save the temporary regs
	rcall	clocktick			; Call the main clock tick
	pop		r27					; Restore the registers
	pop		r26
	pop		r19
	pop		r18
	pop		r25					; Restore the status register
	pop		r24
	out		SREG,r24
	pop		r24
	reti						; Return from interrupt
	.endfunc
;
; Fin.
