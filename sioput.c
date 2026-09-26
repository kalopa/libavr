/*
 * Copyright (c) 2007-26, Kalopa Robotics Limited.  All rights reserved.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.  It is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this product; see the file COPYING.  If not, write to the
 * Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * ABSTRACT
 * A precis on ring buffers. Each one is 32 bytes long (see below). The
 * head and tail pointers are unsigned chars. This code can directly
 * manipulate :ohead and the ISR can manipulate :otail. If :ohead ==
 * :otail then the buffer is empty. If :ohead+1 (modulo 32) is equal
 * to :otail then the buffer is full. In blocking mode, compute :ohead
 * + 1 and then wait for :otail to move. If :ohead+1 is not equal to
 * :otail, then stick the outgoing character into the :ohead position
 * and advance :ohead. Also make sure to re-enable TX interrupts in case
 * they were disabled. See sioget.c as well.
 */
#include <stdio.h>
#include <avr/io.h>

#include "libavr.h"
#include "oldregs.h"

/*
 * :direct_mode means don't use interrupts or ring buffers, just poll
 * the device.  :ohead and :otail are ring buffer pointers. :oring is
 * the output ring buffer. Note that the ring size is hard-coded to
 * 32. If you change it here, you need to change it in the ISR too.
 */
uchar_t				direct_mode = 0;
volatile uchar_t	ohead = 0;
volatile uchar_t	otail = 0;
volatile uchar_t	oring[32];

/*
 * Add a character the outbound ring buffer. In direct mode, wait for the
 * UART status to be ready and stick the character in the output register.
 * If :blockf is non-zero, then wait for space in the output ring buffer.
 */
void
sio_enqueue(char ch, char blockf)
{
	if (direct_mode) {
#if 0
		/*
		 * Wait for the UART output buffer to be free.
		 */
		if (!(UCSR0A & (1<<UDRE0)) && blockf == 0)
			return;
		while (!(UCSR0A & (1<<UDRE0)))
			_watchdog();
		UDR0 = ch;
		return;
#endif
	} else {
		uchar_t nexthead;

		/*
		 * Wait for space in the ring buffer...
		 */
		cli();
		if ((nexthead = (ohead + 1) & 31) == otail && blockf == 0) {
			sei();
			return;
		}
		while (nexthead == otail) {
			sei();
			_sio_txinton();
			_watchdog();
			cli();
		}
		oring[ohead] = ch;
		ohead = (ohead + 1) & 31;
		_sio_txinton();
		sei();
	}
}

/*
 * Interface for AVR library which wants a libc-style fputc. Also cook
 * the output.
 */
int
sio_putc(char ch, FILE *fp)
{
	if (ch == '\n')
		sio_enqueue('\r', 1);
	sio_enqueue(ch, 1);
	return(0);
}

/*
 * Wait for the output queue to drain.
 */
void
sio_oqueue_drain()
{
	if (ohead == otail)
		return;
	sei();
	_sio_txinton();
	while (ohead != otail)
		;
}

/*
 * Enable direct output (no buffering). Useful for debugging a crash where
 * the system halts with data still in the output buffer.
 */
void
sio_set_direct_mode(uchar_t mode)
{
	direct_mode = mode;
}

/*
 * Return the status of the output queue.  True means empty.
 */
int
sio_oqueue_empty()
{
	return(ohead == otail);
}
