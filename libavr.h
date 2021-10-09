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

/*
 * Some inline assembly functions...
 */
#ifndef sei
#define sei()  __asm__ __volatile__ ("sei" ::)
#define cli()  __asm__ __volatile__ ("cli" ::)
#endif

/*
 * Some useful typedefs...
 */
typedef unsigned char	uchar_t;
typedef unsigned int	uint_t;
typedef unsigned long	ulong_t;

/*
 * This structure is used to maintain the specific parameters for
 * a PID controller.
 */
struct	pid	{
	int			kp;
	int			ki;
	int			kd;
	uint_t		k_div;
	int			e_sigma;
	int			e_prev;
	uint_t		u_mul;
	uint_t		u_div;
};

/*
 * Linked list for timer callbacks.
 */
struct thread {
	struct thread	*next;
	uint_t			tick;
	uint_t			(*func)();
};

/*
 * Prototypes for functions in libavr.a
 */
int		sio_getc(FILE *);
int		sio_putc(char, FILE *);
void	sio_setecho(int);
int		sio_dequeue(char);
void	sio_enqueue(char, char);
int		sio_iqueue_empty();
int		sio_oqueue_empty();
int		analog_read(int);

int		pidcalc(struct pid *, int);

int		timer_callback(unsigned int (*)(), int);
void	timer_enqueue(struct thread *);
void	timer_loop();
void	timer_tick();

void	_reset();
void	_sleep();
void	_watchdog();
void	_wdenable();
void	_setled(uchar_t);
void	_bootstrap();
void	_sio_rxinton();
void	_sio_rxintoff();
void	_sio_txinton();
void	_sio_txintoff();
void	_ana_start(uchar_t);
uint_t	_ana_read();
