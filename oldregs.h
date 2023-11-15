/*
 * Copyright (c) 2007-23, Kalopa Robotics Limited.  All rights reserved.
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

/*
 * Fix short register names.
 */
#if defined (__AVR_ATmega8__)
#define SPMCSR		SPMCR
#define UCSR0A		UCSRA
#define UCSR0B		UCSRB
#define UCSR0C		UCSRC
#define UBRR0H		UBRRH
#define UBRR0L		UBRRL
#define UDR0		UDR
#define UDRE0		UDRE
#endif
