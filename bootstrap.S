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
; This bootstrap module can be used by the Kalopa AVR programmer to
; program the flash memory over the serial port. For more info, see
;
; https://github.com/kalopa/kprog.git
;
; For the ATMega328, the application firmware runs from 0x0000 to
; 0x3eff and the boot loader runs from 0x3f00 to 0x3fff (word
; addressing). This allows for 256 words (512 bytes) of bootstrap
; instructions, or four pages.
;
; BOOTSZ1=1, BOOTSZ0=1.
;
; The bootstrap subprogram is invoked by calling _bootstrap from the main
; code. It will reconfigure the serial port and runs without interrupts. The
; serial port will now run at 9600 baud (slower for better reliability).
;
; The serial commands are as follows:
;	0-7xx	Upload 16 bytes of program data to memory
;	Dnn		Dump page 'nn' of program flash
;	Ebb		Erase a block (bb) of flash memory
;	M		Dump the memory buffer
;	Pbb		Program a block (bb) of flash memory
;	R		Reset the system (jump to zero)
;
; The argument to the dump command is the upper byte of the address. So
; D7F will dump from 7f00 through 7fff. The argument to the Erase and
; Program commands is a block number in the range 00->FF, so they work
; on blocks of 128 bytes. As the upload command only accepts 16 bytes,
; you need 8 of them to upload a complete block into memory.
;
; Success is indicated by a '+' and an error by a '-'. As it is sometimes
; possible to get lost in a command, there is a sync character '!' which
; can be produced by sending a carriage-return (repeatedly). So if you
; don't know if you're in a command which wants input and you want to abort,
; keep hitting return until you see the resync.
;
; To bootstrap memory, upload 128 bytes of block data, 16 bytes at a time,
; using the 0 through 7 commands. You can verify what you've uploaded by
; using the M command. You can erase a block of flash (other than this
; code) by using the 'E' command, and then the 'P' command for the block.
; use the 'D' command to dump 256 bytes of flash memory, to verify the
; programming correctly. Bear in mind that the 'nn' argument to the D
; command is not the same as the 'bb' argument to the E and P commands.
;
; To upload sixteen bytes to the end of the memory buffer (112->127) use a
; command such as:
;	790.91.92.93.94.95.96.97.98.99.9A.9B.9C.9D.9E.9F.
; The command is 7, followed by 16 hex values, each separated/terminated by
; a full stop. You can verify this has happened, via the 'M' command.
;
; WARNING/LIMITATIONS:
; As of now, this code is very hard-wired to the ATMega328p, and occupies
; around 460 bytes of code. It needs to be made more portable...
;
; The baud rate is a tricky one. This code does not want to assume that
; the serial port has been configured. It first checks that the serial
; device is enabled - if so, it assumes everything has been configured
; correctly. Otherwise, it'll configure the stack and the serial port.
; It will set a slow baud rate (9600) to minimize errors over the serial
; line.
;
#include <avr/io.h>
#include "oldregs.h"
;
; void _bootstrap();
;
        .section .bstrap0,"ax",@progbits
;
	.global	_bootstrap
	.func	_bootstrap
_bootstrap:
	cli								; No interrupts, please!
	clr		r1
	out		_SFR_IO_ADDR(SREG),r1
	in		r31,_SFR_IO_ADDR(SPH)	; Save the stack pointer (for debug)
	in		r30,_SFR_IO_ADDR(SPL)
	lds		r24,UCSR0B				; Get the serial port CSR
	andi	r24,0x18				; Is it initialized?
	brne	1f
;
; Serial port not enabled - set it up with the stack. Configure the UART for
; serial communications at 9600 baud (polled).
	ldi		r16,lo8(RAMEND)			; Set up the stack pointer
	ldi		r17,hi8(RAMEND)
	out		_SFR_IO_ADDR(SPH),r17
	out		_SFR_IO_ADDR(SPL),r16
;
	ldi		r24,103					; Baud rate to 9600 @ 16MHz
	sts		UBRR0H,r1
	sts		UBRR0L,r24
	ldi		r24,0x06				; UCSZ01|UCSZ00
	sts		UCSR0C,r24
;
1:	ldi		r24,0x18				; RXEN0|TXEN0
	sts		UCSR0B,r24
	rcall	.z_out
;
	ldi		r31,hi8(_bstrap_msg)	; Point to start message
	ldi		r30,lo8(_bstrap_msg)
2:	lpm		r24,Z+					; Get each character
	tst		r24						; End of string?
	breq	.mloop					; Yeah - go to start
	rcall	.ser_out					; Output character
	rjmp	2b						; Get next
;
.good:
	ldi		r24,'+'					; Confirm success
	rcall	.ser_out
;
.mloop:
	ldi		r24,'\n'				; Output a CR/LF
	rcall	.ser_out
	ldi		r24,'@'				; Output a CR/LF
	rcall	.ser_out
	rcall	.ser_in					; Read a command character
	cpi		r24,'\r'				; Carriage-return?
	breq	.mloop					; No, try the next option
;
; Reset the board?
	cpi		r24,'R'					; Reset command?
	brne	.chkd					; No, try the next option
#ifdef __AVR_HAVE_JMP_CALL__
	jmp		0						; Easy - just go to the zero addr
#else
	rjmp	0						; Easy - just go to the zero addr
#endif
;
; Dump?
.chkd:
	cpi		r24,'D'
	brne	.chkm					; No, try the next option
	rcall	.get_hex8				; Get the block address
	brcs	.error
	mov		r31,r24					; Set up the Z register
	clr		r30
;
	ldi		r16,16					; Sixteen lines of output
1:	ldi		r17,16					; Sixteen bytes in each
	ldi		r24,'P'					; Start with a 'P' (Flash output)
	rcall	.ser_out
	rcall	.z_out					; Output the address
2:	ldi		r24,' '					; Lead with a space
	rcall	.ser_out
	lpm		r24,Z+					; Fetch the program byte
	rcall	.hex_out					; Output it
	dec		r17						; Inner loop decrement
	brne	2b
	ldi		r24,'\n'				; End of line
	rcall	.ser_out
	dec		r16						; Outer loop decrement
	brne	1b
	rjmp	.good					; And we're done!
;
; Dump the memory buffer?
.chkm:
	cpi		r24,'M'					; Dump memory buffer?
	brne	.chkn					; No, try the next option
;
	ldi		r31,hi8(0x100)			; Set the memory address
	ldi		r30,lo8(0x100)
	ldi		r16,8					; Eight lines of output
1:	ldi		r17,16					; Sixteen bytes in each
	ldi		r24,'M'					; Start with an 'M' (memory output)
	rcall	.ser_out
	mov		r24,r30
	rcall	.hex_out					; Output the address
2:	ldi		r24,' '					; Lead with a space
	rcall	.ser_out
	ld		r24,Z+					; Read the memory address
	rcall	.hex_out					; Output it
	dec		r17						; Inner loop decrement
	brne	2b
	ldi		r24,'\n'				; End of line
	rcall	.ser_out
	dec		r16						; Outer loop decrement
	brne	1b
	rjmp	.good					; And we're done!
;
; Report an error and try again.
.error:
	ldi		r24,'-'					; Output brief error message
	rcall	.ser_out
	rjmp	.mloop					; Try again...
;
; Program?
.chkn:
	cpi		r24,'0'					; >= '0'?
	brlt	.chke					; No, try the next option
	cpi		r24,'8'					; <= '7'?
	brge	.chke					; No, try the next option
	subi	r24,'0'					; Ok, convert from ASCII
	lsl		r24						; Convert to a memory address
	lsl		r24
	lsl		r24
	lsl		r24
	mov		r30,r24
	ldi		r31,hi8(0x100)
;
; Program code.
	ldi		r16,16					; Retrieve sixteen bytes
1:	rcall	.get_hex8				; Get each data value
	st		Z+,r24					; Store it in memory
	rcall	.ser_in					; Delimit with dots
	cpi		r24,'.'
	brne	.error					; No? Data error - give up
	dec		r16						; Decrement loop
	brne	1b						; Keep going for all 16
	rjmp	.good					; Now we're done
;
; Erase a page?
.chke:
	cpi		r24,'E'					; 'E' command?
	brne	.chkp					; No, try the next option
	rcall	.get_hex8				; Get page address
	brcs	.error
	mov		r25,r24					; Disallow bootloader erase
	andi	r25,0xfc
	cpi		r25,0xfc
	breq	.error					; Error - trying to access boot loader
;
; Erase a page in flash
	rcall	.page_conv				; Convert to a memory (byte) address
	ldi		r24,(1<<PGERS)|(1<<SPMEN)	; Do page erase
	rcall	.do_spm
	ldi		r24,(1<<RWWSRE)|(1<<SPMEN)	; Re-enable RWW section
	rcall	.do_spm
	rjmp	.good
;
; Write a block?
.chkp:
	cpi		r24,'P'					; 'P' command?
	brne	.error					; No, then we have an error
	rcall	.get_hex8				; Get page address
	brcs	.error
	mov		r25,r24					; Disallow bootloader programming
	andi	r25,0xfc
	cpi		r25,0xfc
	breq	.error					; Error - trying to write boot loader
;
; Write a page from memory
	rcall	.page_conv				; Convert to a memory (byte) address
	ldi		r16,64					; 64 words per page
	ldi		r28,lo8(0x100)			; Y = 0x100
	ldi		r29,hi8(0x100)
	push	r30						; Save the memory address for later
	push	r31
1:	ld		r0,Y+					; Load a word from memory
	ld		r1,Y+
	ldi		r24,(1<<SPMEN)			; Write it using the SPM instruction
	rcall	.do_spm
	adiw	r30,2					; Next word address
	dec		r16						; Decrement count
	wdr
	brne	1b						; Keep going until page done
;
	pop		r31						; Restore memort address
	pop		r30
	ldi		r24,(1<<PGWRT)|(1<<SPMEN)	; Do page write
	rcall	.do_spm
	ldi		r24,(1<<RWWSRE)|(1<<SPMEN)	; Re-enable RWW section
	rcall	.do_spm
	rjmp	.good
;
; Do an SPM operation (SPMCSR value in r24)
.do_spm:
	in		r25,_SFR_IO_ADDR(SPMCSR)	; Read the SPM CSR
	sbrc	r25,SPMEN				; Check bit0 (SPMEN=0)
	rjmp	.do_spm					; Retry...
	out		_SFR_IO_ADDR(SPMCSR),r24	; Write new CSR value
	spm
	ret
;
; Convert r24 to 16bit (Z) page address
.page_conv:
	mov		r30,r24					; Move r24 to Z
	clr		r31
	ldi		r24,7					; Page size << 7
1:	lsl		r30						; Shift LSB (into C)
	rol		r31						; Shift MSB (from C)
	dec		r24						; Continue...
	brne	1b
	ret
;
; Read a 8-bit hex value.
.get_hex8:
	rcall	.get_hex4				; Get a nybble (bits7:4)
	brcs	1f						; Error? abort now.
	swap	r24						; Move to upper bits
	mov		r25,r24					; Save in r25
	rcall	.get_hex4				; Get other nybble (bits3:0)
	brcs	1f						; Error? abort now
	or		r24,r25					; Add in the upper bits
1:	ret
;
; Read a hex nybble.
.get_hex4:
	clc								; Clear the C bit (just in case)
	rcall	.ser_in					; Get one character
	cpi		r24,'0'					; Less than '0'?
	brlt	2f						; Yeah - fail
	cpi		r24,':'					; Greater than '9'?
	brge	1f						; Yeah - maybe it's [A-F]
	subi	r24,'0'					; Subtract ASCII
	clc								; Clear carry, and we're done
	ret
1:	cpi		r24,'A'					; Less than 'A'?
	brlt	2f						; Yeah - fail
	cpi		r24,'G'					; Greater than 'F'?
	brge	2f						; Again, fail
	subi	r24,55					; Remove ASCII
	clc								; Clear carry, and we're done
	ret
;
2:	sec								; Failed - set carry and return
	ret
;
; Input a character from the serial port to r24.
.ser_in:
	lds		r24,UCSR0A				; Get the UART status
	wdr							; Kick the watchdog timer
	sbrs	r24,7					; RXC0 set?
	rjmp	.ser_in					; No. Try again.
	lds		r24,UDR0				; Receive the character
	cpi		r24,'a'					; Convert to uppercase
	brlt	1f
	cpi		r24,'z'+1
	brge	1f
	subi	r24,32
1:	cpi		r24,5					; ^E? Ignore...
	breq		.ser_in
	cpi		r24,'\\'				; Backslash? Reset.
	brne		2f
#ifdef __AVR_HAVE_JMP_CALL__
	jmp		_bootstrap
#else
	rjmp	_bootstrap
#endif
2:	ret
;
; Output the contents of the 'Z' register
.z_out:
	mov		r24,r31					; Get the high byte
	rcall	.hex_out					; Output it
	mov		r24,r30					; Get the low byte
;
; Output an 8-bit HEX value from r24.
.hex_out:
	push	r24						; Save value for now
	swap	r24						; Get high 4 bits
	rcall	1f						; Call our local function
	pop		r24						; Now restore original value
;
1:	andi	r24,0x0f				; Only want lower 4 bits
	subi	r24,-48					; Add '0'
	cpi		r24,':'					; If it's less than 10...
	brlt	.ser_out					; ... output it
	subi	r24,-7					; Adjust for A-F
;
; Output the character in r24 to the serial port
.ser_out:
	cpi		r24,'\n'				; Is this a newline?
	brne	1f						; No - handle normally
	ldi		r24,'\r'				; Yes - first output a CR
	rcall	1f
	ldi		r24,'\n'				; Now output the LF
;
1:	lds		r25,UCSR0A				; Get the UART status
	wdr							; Kick the watchdog timer
	sbrs	r25,5					; UDRE0 set?
	rjmp	1b						; No. Try again.
	sts		UDR0,r24				; Send the character
	ret
;
	.global	_bstrap_msg
_bstrap_msg:
	.string	"\nBOOTv2"
	.endfunc
;
; Fin
