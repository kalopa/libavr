;
; Port definitions for the ATmega328P (for use in assembly code).
;
PINB=	0x03
DDRB=	0x04
PORTB=	0x05
PINC=	0x06
DDRC=	0x07
PORTC=	0x08
PIND=	0x09
DDRD=	0x0A
PORTD=	0x0B
TIFR0=	0x15
TIFR1=	0x16
TIFR2=	0x17
PCIFR=	0x1B
EIFR=	0x1C
EIMSK=	0x1D
GPIOR0=	0x1E
EECR=	0x1F
EEDR=	0x20
EEARL=	0x21
EEARH=	0x22
GTCCR=	0x23
TCCR0A=	0x24
TCCR0B=	0x25
TCNT0=	0x26
OCR0A=	0x27
OCR0B=	0x28
GPIOR1=	0x2A
GPIOR2=	0x2B
SPCR=	0x2C
SPSR=	0x2D
SPDR=	0x2E
ACSR=	0x30
SMCR=	0x33
MCUSR=	0x34
MCUCR=	0x35
SPMCSR=	0x37
PINB=	0x03
DDRB=	0x04
PORTB=	0x05
PINC=	0x06
DDRC=	0x07
PORTC=	0x08
PIND=	0x09
DDRD=	0x0A
PORTD=	0x0B
TIFR0=	0x15
TIFR1=	0x16
TIFR2=	0x17
PCIFR=	0x1B
EIFR=	0x1C
EIMSK=	0x1D
GPIOR0=	0x1E
EECR=	0x1F
EEDR=	0x20
EEARL=	0x21
EEARH=	0x22
GTCCR=	0x23
TCCR0A=	0x24
TCCR0B=	0x25
TCNT0=	0x26
OCR0A=	0x27
OCR0B=	0x28
GPIOR1=	0x2A
GPIOR2=	0x2B
SPCR=	0x2C
SPSR=	0x2D
SPDR=	0x2E
ACSR=	0x30
SMCR=	0x33
MCUSR=	0x34
MCUCR=	0x35
SPMCSR=	0x37
SPL=	0x3d
SPH=	0x3e
SREG=	0x3f
;
; The following are memory addresses, *not* port addresses.
WDTCSR=	0x60
CLKPR=	0x61
PRR=	0x64
OSCCAL=	0x66
PCICR=	0x68
EICRA=	0x69
PCMSK0=	0x6b
PCMSK1=	0x6c
PCMSK2=	0x6d
TIMSK0=	0x6e
TIMSK1=	0x6f
TIMSK2=	0x70
ADCL=	0x78
ADCH=	0x79
ADCSRA=	0x7a
ADCSRB=	0x7b
ADMUX=	0x7c
DIDR0=	0x7e
DIDR1=	0x7f
TCCR1A=	0x80
TCCR1B=	0x81
TCCR1C=	0x82
TCNT1L=	0x84
TCNT1H=	0x85
ICR1L=	0x86
ICR1H=	0x87
OCR1AL=	0x88
OCR1AH=	0x89
OCR1BL=	0x8a
OCR1BH=	0x8b
TCCR2A=	0xb0
TCCR2B=	0xb1
TCNT2=	0xb2
OCR2A=	0xb3
OCR2B=	0xb4
ASSR=	0xb6
TWBR=	0xb8
TWSR=	0xb9
TWAR=	0xba
TWDR=	0xbb
TWCR=	0xbc
TWAMR=	0xbd
UCSR0A=	0xc0
UCSR0B=	0xc1
UCSR0C=	0xc2
UBRR0L=	0xc4
UBRR0H=	0xc5
UDR0=	0xc6
;
; Memory constants...
RAMEND=		0x8ff
FLASHEND=	0x3ffff
BSBASE=		0xf00
;
; Page constraints
PAGESIZE=32
PAGESIZEB=PAGESIZE*2
NPAGES=128
