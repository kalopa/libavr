/*
 * Copyright (c) 2020-24, Kalopa Robotics Limited.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ABSTRACT
 * This is where the low-level serial peripheral interface (SPI) activity
 * takes place. Functions to read and write a byte over the SPI port are
 * contained in here, and in the low-level _setss() function. Eventually
 * this stuff will operate via interrupts, but for now it is polled.
 */
#include <stdio.h>
#include <avr/io.h>
#include <libavr.h>

/*
 * Initialize the SPI circuit in the Atmel chip. We are running at a speed
 * of 1MHz with interrupts enabled.
 */
void
spi_init()
{
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
}

/*
 * Send and receive a byte over the SPI bus. Only wait about 20ms for the
 * return (64,000 x 5 instructions at 16MHz).
 */
int
spi_byte(uchar_t byte)
{
	unsigned int i;

	SPDR = byte;
	for (i = 0; i < 64000 && (SPSR & (1<<SPIF)) == 0; i++)
		;
	if (i == 64000)
		return(-1);
	return(SPDR & 0xff);
}
