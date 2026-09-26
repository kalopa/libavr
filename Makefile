#
# Copyright (c) 2007-26, Kalopa Robotics Limited.  All rights reserved.
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
	BINDIR?=/usr/local/bin
endif

AVR?=.
DEVICE?=attiny1626
PROG?=usbtiny
# tinyAVR only: size of the BOOT section holding bootstrap.S, in 256-byte
# units (FUSE.BOOTEND). Must match the BOOTEND used by avr.mk when linking
# the application.
BOOTEND?=2

AR=$(BINDIR)/avr-ar
AS=$(BINDIR)/avr-as
CC=$(BINDIR)/avr-gcc
GCC=$(BINDIR)/avr-gcc
LD=$(BINDIR)/avr-ld
NM=$(BINDIR)/avr-nm
OBJDUMP=$(BINDIR)/avr-objdump
RANLIB=$(BINDIR)/avr-ranlib
STRIP=$(BINDIR)/avr-strip

ASFLAGS=-mmcu=$(DEVICE) -I$(AVR) -DBOOTSTRAP -DBSTRAP_BOOTEND=$(BOOTEND) -Wa,-adhlns=$(<:%.S=%.lst)
#ASFLAGS=-mmcu=$(DEVICE) -I$(AVR) -DBOOTSTRAP
CFLAGS=-Wall -O2 -mmcu=$(DEVICE) -I$(AVR) -DBOOTSTRAP -Wa,-adhlns=$(<:%.c=%.lst)
#CFLAGS=-Wall -O2 -mmcu=$(DEVICE) -I$(AVR) -DBOOTSTRAP
LDFLAGS=-nostartfiles -L.
LIBS=	-lavr

ASRCS=	reset.S watchdog.S wdenable.S \
	clkint.S sleep.S setled.S \
	sioint.S pktint.S \
	spi_irq.S anastart.S anaread.S \
	bootstrap.S
#CSRCS=	event.c sioget.c sioput.c spi.c analog.c pid.c
CSRCS=	event.c sioget.c sioput.c pid.c
OBJS=	$(ASRCS:.S=.o) $(CSRCS:.c=.o)
LIB=	libavr.$(DEVICE).a

all:	$(LIB)

clean:
	rm -f $(OBJS) $(LIB) *.lst errs

$(LIB): $(OBJS)
	$(AR) cru $(LIB) $?

$(OBJS): libavr.h
