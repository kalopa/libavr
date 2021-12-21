#
# Copyright (c) 2007-21, Kalopa Robotics Limited.  All rights reserved.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.  It is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this product; see the file COPYING.  If not, write to the
# Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
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

DEVICE?=atmega328p
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

#ASFLAGS= -mmcu=$(DEVICE) -I$(AVR) -Wa,-adhlns=$(<:%.S=%.lst)
ASFLAGS= -mmcu=$(DEVICE) -I$(AVR)
CFLAGS=	-Wall -O2 -mmcu=$(DEVICE) -I$(AVR)
LDFLAGS=-nostartfiles -L.
LIBS=	-lavr

ASRCS=	reset.S \
	clkint.S watchdog.S sleep.S \
	serinten.S sioint.S pktint.S \
	anastart.S anaread.S \
	setled.S \
	bootstrap.S
CSRCS=	event.c sioget.c sioput.c analog.c pid.c
OBJS=	$(ASRCS:.S=.o) $(CSRCS:.c=.o)
LIB=	libavr.$(DEVICE).a

all:	$(LIB)

clean:
	rm -f $(LIB) $(OBJS) *.lst errs

$(LIB): $(OBJS)
	$(AR) cru $(LIB) $?

$(OBJS): libavr.h
