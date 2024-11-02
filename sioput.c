/*
 * Copyright (c) 2007-21, Kalopa Robotics Limited.  All rights reserved.
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
 */
#include <stdio.h>
#include <avr/io.h>

#include "libavr.h"
#include "oldregs.h"

uchar_t				direct_mode = 0;
uchar_t				ohead = 0;
volatile uchar_t	otail = 0;
uchar_t				oring[32];

/*
 * Wait for the output queue to drai.
 */
void
sio_oqueue_drain()
{
	while (ohead != otail)
		;
}

/*
 * Check if the output queue is empty.
 */
int
sio_oqueue_empty()
{
	return(ohead == otail);
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
 * Add a character the outbound ring buffer.
 */
void
sio_enqueue(char ch, char blockf)
{
	uchar_t head, tail;

	if (direct_mode) {
		while (!(UCSR0A & (1<<UDRE0)))
			;
		UDR0 = ch;
		return;
	}
	/*
	 * Wait for space in the ring buffer...
	 */
	head = (ohead + 1) & 31;
	do {
		tail = otail;
		_watchdog();
	} while (head == tail && blockf);
	cli();
	if (head != tail) {
		oring[ohead] = ch;
		ohead = (ohead + 1) & 31;
	}
	_sio_txinton();
	sei();
}

/*
 *
 */
int
sio_putc(char ch, FILE *fp)
{
	if (ch == '\n')
		sio_enqueue('\r', 1);
	sio_enqueue(ch, 1);
	return(0);
}
