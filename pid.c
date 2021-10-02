/*
 * Copyright (c) 2013-21, Kalopa Robotics Limited.  All rights reserved.
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
 * This is the heart of the PID controller.
 */
#include <stdio.h>

#include "libavr.h"

/*
 * Calculate the U value for a specific PID controller given a
 * particular E value.
 */
int
pidcalc(struct pid *pp, int e)
{
	int bige, u, bigu, delta, awu;

	bige = e * pp->k_div;
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
	return(u);
}
