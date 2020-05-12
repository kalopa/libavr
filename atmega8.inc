;
; Copyright (c) 2007, Kalopa Research Limited.  All rights reserved.
; Unpublished rights reserved under the copyright laws of the United
; States and/or the Republic of Ireland.
;
; The software contained herein is proprietary to and embodies the
; confidential technology of Kalopa Research Limited.  Possession,
; use, duplication or dissemination of the software and media is
; authorized only pursuant to a valid written license from Kalopa
; Research Limited.
;
; RESTRICTED RIGHTS LEGEND   Use, duplication, or disclosure by the
; U.S.  Government is subject to restrictions as set forth in
; Subparagraph (c)(1)(ii) of DFARS 252.227-7013, or in FAR 52.227-19,
; as applicable.
;
; THIS SOFTWARE IS PROVIDED BY KALOPA RESEARCH LIMITED "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
; PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL KALOPA
; RESEARCH LIMITED BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
; USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
; AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
; IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
; THE POSSIBILITY OF SUCH DAMAGE.
;
SREG=		0x3f
SPH=		0x3e
SPL=		0x3d
GIMSK=		0x3b
GICR=		0x3b			; new name for GIMSK
GIFR=		0x3a
TIMSK=		0x39
TIFR=		0x38
SPMCR=		0x37
I2CR=		0x36
TWCR=		0x36
MCUCR=		0x35
MCUSR=		0x34			; For compatibility,
MCUCSR=		0x34			; keep both names until further
TCCR0=		0x33
TCNT0=		0x32
OSCCAL=		0x31
SFIOR=		0x30
TCCR1A=		0x2f
TCCR1B=		0x2e
TCNT1H=		0x2d
TCNT1L=		0x2c
OCR1AH=		0x2b
OCR1AL=		0x2a
OCR1BH=		0x29
OCR1BL=		0x28
ICR1H=		0x27
ICR1L=		0x26
TCCR2=		0x25
TCNT2=		0x24
OCR2=		0x23
ASSR=		0x22
WDTCR=		0x21
UBRRH=		0x20			;  Note! UCSRC equals UBRRH
EEARH=		0x1f
EEARL=		0x1e
EEDR=		0x1d
EECR=		0x1c
PORTB=		0x18
DDRB=		0x17
PINB=		0x16
PORTC=		0x15
DDRC=		0x14
PINC=		0x13
PORTD=		0x12
DDRD=		0x11
PIND=		0x10
SPDR=		0x0f
SPSR=		0x0e
SPCR=		0x0d
UDR=		0x0c
UCSRA=		0x0b
UCSRB=		0x0a
UCSRC=		0x20			;  Note! UCSRC equals UBRRH
UBRRL=		0x09
ACSR=		0x08
ADMUX=		0x07
ADCSR=		0x06
ADCH=		0x05
ADCL=		0x04
I2DR=		0x03
I2AR=		0x02
I2SR=		0x01
I2BR=		0x00
TWDR=		0x03
TWAR=		0x02
TWSR=		0x01
TWBR=		0x00
;
; Memory constants...
RAMEND=		0x45f
FLASHEND=	0xfff
BSBASE=		0xf00
;
; Page constraints
PAGESIZE=32
PAGESIZEB=PAGESIZE*2
NPAGES=128
