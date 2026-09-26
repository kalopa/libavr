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
# Include file for AVR Makefiles...
#
OS?=$(shell uname)

ifeq (${OS}, Darwin)
	BINDIR=/opt/homebrew/bin
else
	BINDIR=/usr/local/bin
endif

AVR?=$(HOME)/libavr
STDPROM=$(AVR)/stdprom.x

PROG?=usbtiny
OBJS?=	$(ASRCS:.S=.o) $(CSRCS:.c=.o)

AR=$(BINDIR)/avr-ar
AS=$(BINDIR)/avr-as
CC=$(BINDIR)/avr-gcc
C++=$(BINDIR)/avr-c++
G++=$(BINDIR)/avr-g++
GCC=$(BINDIR)/avr-gcc
LD=$(BINDIR)/avr-ld
NM=$(BINDIR)/avr-nm
OBJDUMP=$(BINDIR)/avr-objdump
RANLIB=$(BINDIR)/avr-ranlib
STRIP=$(BINDIR)/avr-strip

FIRMWARE?=firmware.hex

ifndef DEVICE
$(error $$DEVICE must be defined - one of atmega8,atmega328p,etc)
endif

# https://eleccelerator.com/fusecalc/fusecalc.php
#
# The bootstrap code (.bstrap0) lives at the top of flash on the classic
# ATmega parts. On the tinyAVR 0/1/2-series (e.g. attiny1626) it lives in
# the BOOT section at the bottom of flash, whose size is set by the
# BOOTEND fuse in 256-byte units, and the application is linked to start
# immediately after it. See bootstrap.S for the gory details.
ifeq ($(DEVICE),atmega328p)
BSMEMORY=0x7e00
LFUSE?=0xef
HFUSE?=0xcd
EFUSE?=0xff
BSLDFLAGS=-Wl,--section-start=.bstrap0=$(BSMEMORY)
else ifeq ($(DEVICE),attiny1626)
BOOTEND?=2
BSMEMORY=0x0000
APPSTART=$(shell printf 0x%04x $$(($(BOOTEND) * 256)))
ASFLAGS+= -DBSTRAP_BOOTEND=$(BOOTEND)
BSLDFLAGS=-Wl,--section-start=.bstrap0=$(BSMEMORY) -Wl,--section-start=.text=$(APPSTART)
else
BSMEMORY=0x1e00
LFUSE?=0xef
HFUSE?=0xc5
EFUSE?=0xff
BSLDFLAGS=-Wl,--section-start=.bstrap0=$(BSMEMORY)
endif

ASFLAGS+= -mmcu=$(DEVICE) -I$(AVR)
CFLAGS=	-Wall -Os -mmcu=$(DEVICE) -I$(AVR)
#LDFLAGS=-nostartfiles -u __vectors -mmcu=$(DEVICE) -L$(AVR) $(BSLDFLAGS)
LDFLAGS=-nostartfiles -mmcu=$(DEVICE) -L$(AVR) $(BSLDFLAGS)
LIBS=	-lavr.$(DEVICE)

all:	$(BIN)

clean:
	rm -f $(BIN) $(OBJS) $(FIRMWARE) \
	*.lst srclist.ps srclist.pdf errs

program: $(FIRMWARE)
	sudo avrdude -p $(DEVICE) -c $(PROG) -U flash:w:$(FIRMWARE):i
	rm $(FIRMWARE)

fuses:
ifeq ($(DEVICE),attiny1626)
	sudo avrdude -p $(DEVICE) -c $(PROG) -U bootend:w:$(BOOTEND):m
else
	sudo avrdude -p $(DEVICE) -c $(PROG) -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m
endif

erase:
	sudo avrdude -p $(DEVICE) -c $(PROG) -e

tags:	$(ASRCS) $(CSRCS)
	ctags $(CSRCS)
	grep '^_.*:$$' $(ASRCS) /dev/null | awk -F: '{printf "%s\t%s\t/^%s:$$/\n", $$2, $$1, $$2}' >> tags
	sort tags > tags-
	mv tags- tags

docs:	srclist.pdf

$(FIRMWARE): $(BIN)
	avr-objcopy -O ihex $(BIN) $(FIRMWARE)

srclist.ps: $(CSRCS) $(ASRCS)
	c2ps $(CSRCS) $(ASRCS) > srclist.ps

srclist.pdf: srclist.ps
	ps2pdf srclist.ps srclist.pdf
