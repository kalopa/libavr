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
 * manipulate :itail and the ISR can manipulate :ihead. If :ihead ==
 * :itail then the buffer is empty. If :ihead+1 (modulo 32) is equal
 * to :itail then the buffer is full. In blocking mode, if :ihead ==
 * :itail then there's no data and we should wait. Otherwise, pull the
 * character at :itail and return that. See sioput.c as well.
 */
#include <stdio.h>

#include "libavr.h"

volatile uchar_t	ihead = 0;
uchar_t			itail = 0;
uchar_t			iring[32];
uchar_t			echof = 0;

/*
 * Interface for AVR library which wants a libc-style fgetc. Also cook
 * the input and echo as appropriate.
 */
int
sio_getc(FILE *fp)
{
	char ch;

	if ((ch = sio_dequeue(1)) == '\r')
		ch = '\n';
	if (echof)
		sio_putc(ch, fp);
	return(ch);
}

/*
 * Wait for the input queue to drain.
 */
void
sio_iqueue_drain()
{
	while (ihead != itail)
		;
}

/*
 * Check if the input queue is empty.
 */
int
sio_iqueue_empty()
{
	return(ihead == itail);
}

/*
 * Add a character the outbound ring buffer.
 */
int
sio_dequeue(char blockf)
{
	uchar_t ch, head;

	/*
	 * Wait for a character the ring buffer...
	 */
	do {
		head = ihead;
		_watchdog();
	} while (head == itail && blockf);
	cli();
	if (head == itail)
		ch = 0;
	else {
		ch = iring[itail];
		itail = (itail + 1) & 31;
	}
	sei();
	return(ch);
}

/*
 *
 */
void
sio_setecho(int val)
{
	echof = val;
}
