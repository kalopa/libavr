#
# Copyright (c) 2007-2020, Dermot Tynan / Kalopa Research.  All rights
# reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
REGVALS=$(AVR)/$(DEVICE).inc

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

$(OBJS): $(REGVALS)
