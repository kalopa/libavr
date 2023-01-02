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
 * Run an analog conversion and return the result.
 */
#include <stdio.h>
#include <avr/io.h>

#include "libavr.h"

/*
 *
 */
int
analog_read(int portno)
{
	ADMUX = (1<<REFS0)|(portno & 0xf);
	ADCSRA = (1<<ADEN)|(1<<ADSC)|(1<<ADIF)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
	while ((ADCSRA & (1<<ADIF)) == 0)
		;
	return(ADC);
}
