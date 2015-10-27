#
# Copyright (c) 2007, Kalopa Research.  All rights reserved.  This is free
# software; you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation;
# either version 2, or (at your option) any later version.
#
# It is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this product; see the file COPYING.  If not, write to the Free
# Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#
# THIS SOFTWARE IS PROVIDED BY KALOPA RESEARCH "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL KALOPA RESEARCH BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
# USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ABSTRACT
#
OS?=$(shell uname)

ifeq (${OS}, Darwin)
	BINDIR?=/usr/local/bin
else
ifeq (${OS}, FreeBSD)
	BINDIR?=/usr/local/bin
else
	BINDIR?=/usr/bin
endif
endif

DEVICE?=atmega8
PROG?=usbtiny

AR=$(BINDIR)/avr-ar
AS=$(BINDIR)/avr-as
CC=$(BINDIR)/avr-gcc
GCC=$(BINDIR)/avr-gcc
LD=$(BINDIR)/avr-ld
NM=$(BINDIR)/avr-nm
OBJDUMP=$(BINDIR)/avr-objdump
RANLIB=$(BINDIR)/avr-ranlib
STRIP=$(BINDIR)/avr-strip

ASFLAGS= -mmcu=$(DEVICE)
CFLAGS=	-Wall -O2 -mmcu=$(DEVICE)
LDFLAGS=-nostartfiles -L.
LIBS=	-lavr

ASRCS=	reset.s \
	clkint.s watchdog.s sleep.s \
	rdeeprom.s wreeprom.s \
	serinten.s sioint.s pktint.s \
	anastart.s anaread.s \
	setled.s \
	bootstrap.s
CSRCS=	event.c sioget.c sioput.c analog.c eeprom.c pid.c
OBJS=	$(ASRCS:.s=.o) $(CSRCS:.c=.o)
LIB=	libavr.a

all:	$(LIB)

clean:
	rm -f $(LIB) $(OBJS) errs

$(LIB): $(OBJS)
	$(AR) cru $(LIB) $?

$(OBJS): $(IOREGS) $(REGVALS) avr.h ioregs.h
