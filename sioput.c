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
 *
 */
#include <stdio.h>

#include "libavr.h"

uchar_t			ohead = 0;
volatile uchar_t	otail = 0;
uchar_t			oring[32];

/*
 * Check if the output queue is empty.
 */
int
sio_oqueue_empty()
{
	return(ohead == otail);
}

/*
 * Add a character the outbound ring buffer.
 */
void
sio_enqueue(char ch, char blockf)
{
	uchar_t head, tail;

	/*
	 * Wait for space in the ring buffer...
	 */
	head = (ohead + 1) & 31;
	do {
		tail = otail;
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
