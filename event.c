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
 * My version of a lightweight timer event machine.
 */
#include <stdio.h>
#include <stdlib.h>
#include "avr.h"
#include "ioregs.h"

volatile uchar_t	tick_count = 0;
struct	thread		*thead = NULL;

/*
 * Register a timer callback.
 */
int
timer_callback(unsigned int (*func)(), int tick)
{
	struct thread *tp;

	if ((tp = (struct thread *)malloc(sizeof(struct thread))) == NULL)
		return(-1);
	tp->func = func;
	tp->tick = tick;
	timer_enqueue(tp);
	return(0);
}

/*
 * Enqueue a callback on the appropriate timer queue. The queue is
 * ordered by the relative number of milliseconds between each callback.
 */
void
timer_enqueue(struct thread *tp)
{
	struct thread *ntp;

	if (thead == NULL || thead->tick > tp->tick) {
		/*
		 * Insert at the front.
		 */
		tp->next = thead;
		thead = tp;
	} else {
		for (ntp = thead; ntp->next != NULL; ntp = ntp->next) {
			if (ntp->next->tick > tp->tick)
				break;
		}
		tp->next = ntp->next;
		ntp->next = tp;
	}
	if (tp->next != NULL)
		tp->next->tick -= tp->tick;
}

/*
 * Loop through the timer list, dealing with each timer tick.
 */
void
timer_loop()
{
	struct thread *tp;

	/*
	 * Only run the linked-list if the timer has fired.
	 */
	for (; tick_count > 0; tick_count--) {
		if (thead != NULL && thead->tick > 0)
			thead->tick--;
		while ((tp = thead) != NULL && tp->tick == 0) {
			thead = tp->next;
			if ((tp->tick = tp->func()) > 0)
				timer_enqueue(tp);
			else
				free((char *)tp);
		}
	}
}

/*
 * Ping the timer loop - time has moved on. Called from the Interrupt
 * Service Routine.  Generally a tick happens every 5ms, which is the
 * unit of measure for the event queue.
 */
void
timer_tick()
{
	tick_count++;
}
