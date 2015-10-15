/*
 * Copyright (c) 2007, Kalopa Research Limited.  All rights reserved.
 * Unpublished rights reserved under the copyright laws of the
 * United States and/or the Republic of Ireland.
 *
 * The software contained herein is proprietary to and embodies the
 * confidential technology of Kalopa Research Limited.  Possession,
 * use, duplication or dissemination of the software and media is
 * authorized only pursuant to a valid written license from Kalopa
 * Research Limited.
 *
 * RESTRICTED RIGHTS LEGEND   Use, duplication, or disclosure by
 * the U.S.  Government is subject to restrictions as set forth in
 * Subparagraph (c)(1)(ii) of DFARS 252.227-7013, or in FAR 52.227-19,
 * as applicable.
 *
 * THIS SOFTWARE IS PROVIDED BY KALOPA RESEARCH LIMITED "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL KALOPA
 * RESEARCH LIMITED BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ABSTRACT
 */

/*
 * Some inline assembly functions...
 */
#define sei()  __asm__ __volatile__ ("sei" ::)
#define cli()  __asm__ __volatile__ ("cli" ::)

/*
 * Some useful typedefs...
 */
typedef unsigned char	uchar_t;
typedef unsigned int	uint_t;
typedef unsigned long	ulong_t;

/*
 * Prototypes for functions in libavr.a
 */
int		sio_getc(FILE *);
int		sio_putc(char, FILE *);
void		sio_setecho(int);
int		sio_dequeue(char);
void		sio_enqueue(char, char);
int		sio_iqueue_empty();
int		sio_oqueue_full();
int		analog_read(int);
int		eeprom_rdword(int);
void		eeprom_wrword(int, int);

void		_reset();
void		_sleep();
void		_watchdog();
void		_wdenable();
uchar_t		_rdeeprom(uint_t);
void		_wreeprom(uint_t, uchar_t);
void		_setled(uchar_t);
void		_bootstrap();
void		_sio_rxinton();
void		_sio_rxintoff();
void		_sio_txinton();
void		_sio_txintoff();
void		_ana_start(uchar_t);
uint_t		_ana_read();
