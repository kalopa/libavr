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
; This bootstrap module can be used by the Kalopa AVR programmer to
; program the flash memory over the serial port. For more info, see
;
; https://github.com/kalopa/kprog.git
;
; It supports two quite different families of AVR:
;
; 1. The classic ATmega (ATmega8, ATmega328P, etc). Here the boot loader
;    lives at the TOP of flash. For the ATMega328, the application
;    firmware runs from 0x0000 to 0x3eff and the boot loader runs from
;    0x3f00 to 0x3fff (word addressing). This allows for 256 words (512
;    bytes) of bootstrap instructions, or four pages. BOOTSZ1=1, BOOTSZ0=1.
;    Flash is written with the SPM instruction.
;
; 2. The modern tinyAVR 0/1/2-series and megaAVR 0-series (ATtiny1626,
;    etc - what GCC calls "avrxmega3"). Here the boot loader lives at the
;    BOTTOM of flash, in the BOOT section defined by the FUSE.BOOTEND
;    fuse (in units of 256 bytes). With BOOTEND=2 (the default here) the
;    bootstrap occupies 0x0000 to 0x01ff and the application starts at
;    0x0200. The reset vector always lands in the BOOT section, so the
;    code at address zero checks whether an application is present and
;    jumps to it. Interrupt vectors are (by default) expected at the
;    start of the application section, so the application needs no
;    special handling other than being linked at BSTRAP_APP. Flash is
;    written via the NVMCTRL peripheral and the memory-mapped flash at
;    0x8000. The hardware will not allow the BOOT section to be written
;    by anything other than a UPDI programmer, so the bootstrap code
;    cannot destroy itself.
;
; The bootstrap subprogram is invoked by jumping to _bootstrap from the
; main code (usually on receipt of a ^E\ sequence). It will reconfigure
; the serial port and runs without interrupts. If the serial port is
; already enabled, its configuration (and baud rate) are left alone. If
; not, it is configured for 9600 baud (slower for better reliability).
;
; The serial commands are as follows:
;	0-7xx	Upload 16 bytes of program data to memory
;	Dnn		Dump page 'nn' of program flash
;	Ebb		Erase a block (bb) of flash memory
;	M		Dump the memory buffer (ATmega only)
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
; On start-up, the code sends a banner of the form:
;	BOOTv3 KK SS NN
; where KK is the flash size in kilobytes, SS is the first 128-byte block
; occupied by the bootstrap code and NN is the number of blocks it
; occupies (all in hex). So the ATmega328P reports "BOOTv3 20 FC 04" and
; the ATtiny1626 reports "BOOTv3 10 00 04". This allows the programmer
; to work out what it can (and cannot) reprogram. The banner is preceded
; by the stack pointer at the time of entry, in hex, for debugging.
;
; WARNING/LIMITATIONS:
; The code needs to fit in 512 bytes, which it (barely) does. To make
; that happen on the tinyAVR, the 'M' command has been dropped there.
;
; The baud rate is a tricky one. This code does not want to assume that
; the serial port has been configured. It first checks that the serial
; device is enabled - if so, it assumes everything has been configured
; correctly. Otherwise, it'll configure the stack and the serial port.
; It will set a slow baud rate (9600) to minimize errors over the serial
; line. On the ATmega this assumes a 16MHz clock. On the tinyAVR it
; assumes the reset default clock (the 16 or 20MHz oscillator, as set by
; FUSE.OSCCFG, divided by six) and uses the default USART0 pins (PB2/PB3)
; unless BSTRAP_USART_ALT1 is defined, in which case PA1/PA2 are used.
;
#include <avr/io.h>
#include "oldregs.h"
;
#if defined(__AVR_XMEGA__)
;
; tinyAVR/megaAVR 0-series family. Bootstrap at the bottom of flash.
;
#ifndef BSTRAP_BOOTEND
#define BSTRAP_BOOTEND	2					/* FUSE.BOOTEND (256 byte units) */
#endif
#ifndef BSTRAP_BAUD
#define BSTRAP_BAUD		9600
#endif
#define BSTRAP_APP		(BSTRAP_BOOTEND * 256)	/* Application start address */
#define BSTRAP_BOOTBLK	0						/* First bootstrap block */
#define BSTRAP_NBOOT	(BSTRAP_BOOTEND * 2)	/* Bootstrap blocks (128 bytes) */
#define BSTRAP_NBLKS	(PROGMEM_SIZE / 128)	/* Flash size in blocks */
#define MEMBUF			RAMSTART				/* 128 byte upload buffer */
#define SIO_STATUS		USART0_STATUS			/* Serial status register */
#define SIO_RXBIT		7						/* RXCIF - character available */
#define SIO_TXBIT		5						/* DREIF - ready to transmit */
#define SIO_RXDATA		USART0_RXDATAL
#define SIO_TXDATA		USART0_TXDATAL
#define CCP_SPM			0x9d					/* CCP key for NVMCTRL.CTRLA */
#define NVM_ER			0x02					/* Erase page command */
#define NVM_ERWP		0x03					/* Erase & write page command */
;
; USART BAUD register value = 64 * F_CPU / (16 * baud) = 4 * F_CPU / baud,
; where F_CPU is the reset default of the main oscillator divided by six.
;
#define BAUD_16M		((4 * 16000000 / 6 + BSTRAP_BAUD / 2) / BSTRAP_BAUD)
#define BAUD_20M		((4 * 20000000 / 6 + BSTRAP_BAUD / 2) / BSTRAP_BAUD)
;
#else
;
; Classic ATmega family. Bootstrap at the top of flash.
;
#define BSTRAP_BOOTBLK	(((FLASHEND + 1) / 128) - 4)	/* First bootstrap block */
#define BSTRAP_NBOOT	4						/* Bootstrap blocks (128 bytes) */
#define BSTRAP_NBLKS	((FLASHEND + 1) / 128)	/* Flash size in blocks */
#define MEMBUF			0x100					/* 128 byte upload buffer */
#define SIO_STATUS		UCSR0A					/* Serial status register */
#define SIO_RXBIT		7						/* RXC0 - character available */
#define SIO_TXBIT		5						/* UDRE0 - ready to transmit */
#define SIO_RXDATA		UDR0
#define SIO_TXDATA		UDR0
#endif
;
; void _bootstrap();
;
        .section .bstrap0,"ax",@progbits
;
#if defined(__AVR_XMEGA__)
;
; This is address zero - the reset vector. Every reset lands here. If
; there's an application in flash, run it. Otherwise (the application
; area is erased), fall into the bootstrap code and wait to be programmed.
; The 'R' command also comes through here, via a jump to zero.
	.global	_bstrap_reset
	.func	_bstrap_reset
_bstrap_reset:
	ldi		r30,lo8(BSTRAP_APP+1)	; Z = application reset vector (high byte)
	ldi		r31,hi8(BSTRAP_APP+1)
	lpm		r24,Z					; Erased flash is 0xff (a jump never is)
	cpi		r24,0xff
	breq	_bootstrap				; No application - stay here
	rjmp	BSTRAP_APP				; Otherwise, off we go...
	.endfunc
#endif
;
	.global	_bootstrap
	.func	_bootstrap
_bootstrap:
	cli								; No interrupts, please!
	clr		r1
	out		_SFR_IO_ADDR(SREG),r1
	in		r31,_SFR_IO_ADDR(SPH)	; Save the stack pointer (for debug)
	in		r30,_SFR_IO_ADDR(SPL)
#if defined(__AVR_XMEGA__)
	lds		r24,USART0_CTRLB		; Get the serial port control register
	andi	r24,0xc0				; RXEN|TXEN - is it initialized?
	brne	1f
;
; Serial port not enabled - set it up with the stack. Configure the UART for
; serial communications at 9600 baud (polled), using the reset clock.
	ldi		r16,lo8(RAMEND)			; Set up the stack pointer
	ldi		r17,hi8(RAMEND)
	out		_SFR_IO_ADDR(SPH),r17
	out		_SFR_IO_ADDR(SPL),r16
;
#ifdef BSTRAP_USART_ALT1
	ldi		r24,0x01				; USART0 on PA1 (TXD) & PA2 (RXD)
	sts		PORTMUX_USARTROUTEA,r24
	ldi		r24,0x02				; PA1 is an output
	sts		PORTA_DIRSET,r24
#else
	ldi		r24,0x04				; PB2 (TXD) is an output
	sts		PORTB_DIRSET,r24
#endif
	ldi		r24,lo8(BAUD_16M)		; Assume a 16MHz oscillator...
	ldi		r25,hi8(BAUD_16M)
	lds		r16,FUSE_OSCCFG			; ...unless the fuse says 20MHz
	sbrs	r16,1					; FREQSEL: 1=16MHz, 2=20MHz
	rjmp	2f
	ldi		r24,lo8(BAUD_20M)
	ldi		r25,hi8(BAUD_20M)
2:	sts		USART0_BAUDL,r24
	sts		USART0_BAUDH,r25
	ldi		r24,0x03				; Async, no parity, 1 stop, 8 bits
	sts		USART0_CTRLC,r24
;
1:	ldi		r24,0xc0				; RXEN|TXEN
	sts		USART0_CTRLB,r24
#else
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
#endif
	rcall	.z_out					; Show the stack pointer
=======
	rcall	.z_out
>>>>>>> f88507f4c06b9228096e1f6af4c266b0efabddd5
;
	ldi		r31,hi8(_bstrap_msg)	; Point to start message
	ldi		r30,lo8(_bstrap_msg)
2:	lpm		r24,Z+					; Get each character
	tst		r24						; End of string?
	breq	3f						; Yeah - now the layout
	rcall	.ser_out					; Output character
	rjmp	2b						; Get next
;
; Following the banner string are three bytes describing the flash layout.
3:	ldi		r16,3
4:	ldi		r24,' '					; Space-separated...
	rcall	.ser_out
	lpm		r24,Z+					; Each is a hex byte
	rcall	.hex_out
	dec		r16
	brne	4b
	rjmp	.mloop
;
.good:
	ldi		r24,'+'					; Confirm success
	rcall	.ser_out
;
.mloop:
	ldi		r24,'\n'				; Output a CR/LF
	rcall	.ser_out
	ldi		r24,'@'					; Output the prompt
	rcall	.ser_out
	rcall	.ser_in					; Read a command character
	cpi		r24,'\r'				; Carriage-return?
	breq	.mloop					; No, try the next option
;
; Reset the board?
	cpi		r24,'R'					; Reset command?
	brne	.chkd					; No, try the next option
#if defined(__AVR_HAVE_JMP_CALL__) && !defined(__AVR_XMEGA__)
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
; Dump the memory buffer? (Not on the tinyAVR - there isn't room.)
.chkm:
#if !defined(__AVR_XMEGA__)
	cpi		r24,'M'					; Dump memory buffer?
	brne	.chkn					; No, try the next option
;
	ldi		r31,hi8(MEMBUF)			; Set the memory address
	ldi		r30,lo8(MEMBUF)
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
#endif
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
	ldi		r31,hi8(MEMBUF)
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
#if defined(__AVR_XMEGA__)
;
; Erase a block? Each 128 byte block is made up of one or more flash pages.
.chke:
	cpi		r24,'E'					; 'E' command?
	brne	.chkp					; No, try the next option
	rcall	.blk_conv				; Get block address (in Z)
	brcs	.error
	ori		r31,hi8(MAPPED_PROGMEM_START)	; Flash is mapped at 0x8000
	ldi		r16,128/PROGMEM_PAGE_SIZE	; Pages per block
1:	rcall	.nvm_wait				; Wait for the NVM controller
	st		Z,r1					; Dummy write selects the page
	ldi		r24,NVM_ER				; Erase the page
	rcall	.nvm_cmd
	subi	r30,lo8(-PROGMEM_PAGE_SIZE)	; Next page
	sbci	r31,hi8(-PROGMEM_PAGE_SIZE)
	dec		r16
	brne	1b
	rjmp	.good
;
; Write a block?
.chkp:
	cpi		r24,'P'					; 'P' command?
	brne	.error					; No, then we have an error
	rcall	.blk_conv				; Get block address (in Z)
	brcs	.error
	ori		r31,hi8(MAPPED_PROGMEM_START)	; Flash is mapped at 0x8000
	ldi		r28,lo8(MEMBUF)			; Y = memory buffer
	ldi		r29,hi8(MEMBUF)
	ldi		r16,128/PROGMEM_PAGE_SIZE	; Pages per block
1:	rcall	.nvm_wait				; Wait for the NVM controller
	ldi		r17,PROGMEM_PAGE_SIZE	; Fill the page buffer from memory
2:	ld		r0,Y+
	st		Z+,r0
	dec		r17
	brne	2b
	ldi		r24,NVM_ERWP			; Erase & write the page
	rcall	.nvm_cmd
	dec		r16
	brne	1b
	rjmp	.good
;
; Issue an NVM controller command (in r24) and wait for it to complete.
.nvm_cmd:
	ldi		r25,CCP_SPM				; Unlock NVMCTRL.CTRLA
	out		_SFR_IO_ADDR(CCP),r25
	sts		NVMCTRL_CTRLA,r24		; Go!
;
; Wait for the NVM controller to become idle.
.nvm_wait:
	lds		r25,NVMCTRL_STATUS
	wdr								; Kick the watchdog timer
	andi	r25,0x03				; FBUSY|EEBUSY
	brne	.nvm_wait
	ret
;
#else
;
; Erase a block?
.chke:
	cpi		r24,'E'					; 'E' command?
	brne	.chkp					; No, try the next option
	rcall	.blk_conv				; Get block address (in Z)
	brcs	.error
;
; Erase a page in flash
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
	rcall	.blk_conv				; Get block address (in Z)
	brcs	.error
;
; Write a page from memory
	ldi		r16,64					; 64 words per page
	ldi		r28,lo8(MEMBUF)			; Y = memory buffer
	ldi		r29,hi8(MEMBUF)
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
#endif
;
; Read a block number from the serial port, and convert it to a 16bit (Z)
; byte address. Return with the carry set if the block number is invalid
; (bad hex, part of the bootstrap code, or beyond the end of flash).
.blk_conv:
	rcall	.get_hex8				; Get the block number
	brcs	2f						; Bad hex? We're done.
	mov		r25,r24					; Disallow bootstrap erase/program
	subi	r25,BSTRAP_BOOTBLK
	cpi		r25,BSTRAP_NBOOT		; In the bootstrap area?
	brlo	1f						; Yes - error
#if BSTRAP_NBLKS < 256
	cpi		r24,BSTRAP_NBLKS		; Beyond the end of flash?
	brsh	1f						; Yes - error
#endif
	mov		r30,r24					; Move r24 to Z
	clr		r31
	ldi		r24,7					; Block size << 7
3:	lsl		r30						; Shift LSB (into C)
	rol		r31						; Shift MSB (from C)
	dec		r24						; Continue...
	brne	3b
	clc								; All good
	ret
;
1:	sec								; Failed - set carry and return
2:	ret
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
	lds		r24,SIO_STATUS			; Get the UART status
	wdr							; Kick the watchdog timer
	sbrs	r24,SIO_RXBIT			; Character available?
	rjmp	.ser_in					; No. Try again.
	lds		r24,SIO_RXDATA			; Receive the character
	cpi		r24,'a'					; Convert to uppercase
	brlt	1f
	cpi		r24,'z'+1
	brge	1f
	subi	r24,32
1:	cpi		r24,5					; ^E? Ignore...
	breq		.ser_in
	cpi		r24,'\\'				; Backslash? Reset.
	brne		2f
#if defined(__AVR_HAVE_JMP_CALL__) && !defined(__AVR_XMEGA__)
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
1:	lds		r25,SIO_STATUS			; Get the UART status
	wdr							; Kick the watchdog timer
	sbrs	r25,SIO_TXBIT			; Ready to transmit?
	rjmp	1b						; No. Try again.
	sts		SIO_TXDATA,r24			; Send the character
	ret
;
; Sign-on banner, followed by the flash layout: size in KB, first block
; of bootstrap code, number of bootstrap blocks.
	.global	_bstrap_msg
_bstrap_msg:
	.string	"\nBOOTv3"
	.byte	(FLASHEND + 1) / 1024, BSTRAP_BOOTBLK, BSTRAP_NBOOT
	.endfunc
;
; Fin
