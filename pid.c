/*
 * Copyright (c) 2013, Kalopa Research.  All rights reserved.  This is free
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
 * This is the heart of the PID controller.
 */
#include <stdio.h>

#include "libavr.h"
#include "pid.h"

/*
 * Calculate the U value for a specific PID controller given a
 * particular E value.
 */
short
pidcalc(struct pid *pp, short e)
{
	short bige, u, bigu, delta, awu;

	bige = (e * pp->e_mul) / pp->e_div;
	delta = bige - pp->e_prev;
	pp->e_prev = bige;
	awu = pp->e_sigma * pp->ki;
	if (awu < 5000 && awu > -5000) {
		/*
		 * Anti-windup mechanism
		 */
		pp->e_sigma += bige;
	}
	bigu = pp->kp * bige + awu + pp->kd * delta;
	u = (bigu * pp->u_mul) / pp->u_div;
	printf("PID:%d.%d.%d.%d.%d.%d\n", e, bige, delta, pp->e_sigma, bigu, u);
	return(u);
}
