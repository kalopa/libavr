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
# Include file for AVR Makefiles...
#
OS?=$(shell uname)

ifeq (${OS}, Darwin)
	BINDIR=/usr/local/bin
else
ifeq (${OS}, FreeBSD)
	BINDIR=/usr/local/bin
else
	BINDIR=/usr/bin
endif
endif

AVR?=$(HOME)/libavr
STDPROM=$(AVR)/stdprom.x

DEVICE?=atmega8
PROG?=usbtiny
OBJS?=	$(ASRCS:.s=.o) $(CSRCS:.c=.o)

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

# https://eleccelerator.com/fusecalc/fusecalc.php
LFUSE?=0xef
HFUSE?=0xcd
EFUSE?=0xff

ASFLAGS= -mmcu=$(DEVICE) -I$(AVR) -adhlns=$(<:%.s=%.lst)
CFLAGS=	-Wall -O2 -mmcu=$(DEVICE) -I$(AVR) -Wa,-adhlns=$(<:%.c=%.lst)
LDFLAGS=-nostartfiles -mmcu=$(DEVICE) -L$(AVR)
LIBS=	-lavr

all:	$(BIN)

clean:	do_clean

program: do_program

erase:	do_erase

tags:	$(ASRCS) $(CSRCS)
	ctags $(CSRCS)
	grep '^_.*:$$' $(ASRCS) /dev/null | awk -F: '{printf "%s\t%s\t/^%s:$$/\n", $$2, $$1, $$2}' >> tags
	sort tags > tags-
	mv tags- tags

docs:	srclist.pdf

do_clean:
	rm -f $(BIN) $(OBJS) $(FIRMWARE) \
	*.lst srclist.ps srclist.pdf errs

do_erase:
	sudo avrdude -p $(DEVICE) -c $(PROG) -e

do_program: $(FIRMWARE)
	sudo avrdude -p $(DEVICE) -c $(PROG) -U flash:w:$(FIRMWARE):i
	rm $(FIRMWARE)

do_fuses:
	sudo avrdude -p $(DEVICE) -c $(PROG) -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m

$(FIRMWARE): $(BIN)
	avr-objcopy -O ihex $(BIN) $(FIRMWARE)

srclist.ps: $(CSRCS) $(ASRCS)
	c2ps $(CSRCS) $(ASRCS) > srclist.ps

srclist.pdf: srclist.ps
	ps2pdf srclist.ps srclist.pdf
