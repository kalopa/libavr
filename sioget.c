/*
 * Copyright (c) 2007, Kalopa Research.  All rights reserved.  This is free
 * software; you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation;
 * either version 2, or (at your option) any later version.
 *
 * It is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this product; see the file COPYING.  If not, write to the Free
 * Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * THIS SOFTWARE IS PROVIDED BY KALOPA RESEARCH "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL KALOPA RESEARCH BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ABSTRACT
 */
#include <stdio.h>

#include "avr.h"

volatile uchar_t	ihead;
uchar_t			itail;
uchar_t			iring[32];
uchar_t			echof = 0;

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
	} while (head == itail && blockf);
	if (head == itail)
		ch = 0;
	else {
		ch = iring[itail];
		itail = (itail + 1) & 31;
	}
	return(ch);
}

/*
 *
 */
int
sio_getc(FILE *fp)
{
	char ch;

	if ((ch = sio_dequeue(1)) == '\r')
		ch = '\n';
	if (echof)
		sio_putc(ch, NULL);
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
