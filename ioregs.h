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
 *
 * ABSTRACT
 * Definitions for all the ATmega8 registers.
 */
#define SREG		0x5f
#define   SREG_I	0x80
#define   SREG_T	0x40
#define   SREG_H	0x20
#define   SREG_S	0x10
#define   SREG_V	0x08
#define   SREG_N	0x04
#define   SREG_Z	0x02
#define   SREG_C	0x01
#define SPH		0x5e
#define SPL		0x5d
#define GICR		0x5b
#define   GICR_INT1	0x80
#define   GICR_INT0	0x40
#define   GICR_IVSEL	0x02
#define   GICR_IVCE	0x01
#define GIFR		0x5a
#define   GIFR_INTF1	0x80
#define   GIFR_INTF0	0x40
#define TIMSK		0x59
#define   TIMSK_OCIE2	0x80
#define   TIMSK_TOIE2	0x40
#define   TIMSK_TICIE1	0x20
#define   TIMSK_OCIE1A	0x10
#define   TIMSK_OCIE1B	0x08
#define   TIMSK_TOIE1	0x04
#define   TIMSK_TOIE0	0x01
#define TIFR		0x58
#define   TIFR_OCF2	0x80
#define   TIFR_TOV2	0x40
#define   TIFR_ICF1	0x20
#define   TIFR_OCF1A	0x10
#define   TIFR_OCF1B	0x08
#define   TIFR_TOV1	0x04
#define   TIFR_TOV0	0x01
#define SPMCR		0x57
#define   SPMCR_SPMIE	0x80
#define   SPMCR_RWWSB	0x40
#define   SPMCR_RWWSRE	0x10
#define   SPMCR_BLBSET	0x08
#define   SPMCR_PGWRT	0x04
#define   SPMCR_PGERS	0x02
#define   SPMCR_SPMEN	0x01
#define TWCR		0x56
#define   TWCR_TWINT	0x80
#define   TWCR_TWEA	0x40
#define   TWCR_TWSTA	0x20
#define   TWCR_TWSTO	0x10
#define   TWCR_TWWC	0x08
#define   TWCR_TWEN	0x04
#define   TWCR_TWIE	0x01
#define MCUCR		0x55
#define   MCUCR_SE	0x80
#define   MCUCR_SM2	0x40
#define   MCUCR_SM1	0x20
#define   MCUCR_SM0	0x10
#define   MCUCR_ISC11	0x08
#define   MCUCR_ISC10	0x04
#define   MCUCR_ISC01	0x02
#define   MCUCR_ISC00	0x01
#define MCUCSR		0x54
#define   MCUCSR_WDRF	0x08
#define   MCUCSR_BORF	0x04
#define   MCUCSR_EXTRF	0x02
#define   MCUCSR_PORF	0x01
#define TCCR0		0x53
#define   TCCR0_CS02	0x04
#define   TCCR0_CS01	0x02
#define   TCCR0_CS00	0x01
#define TCNT0		0x52
#define OSCCAL		0x51
#define SFIOR		0x50
#define   SFIOR_ACME	0x08
#define   SFIOR_PUD	0x04
#define   SFIOR_PSR2	0x02
#define   SFIOR_PSR10	0x01
#define TCCR1A		0x4f
#define   TCCR1A_COM1A1	0x80
#define   TCCR1A_COM1A0	0x40
#define   TCCR1A_COM1B1	0x20
#define   TCCR1A_COM1B0	0x10
#define   TCCR1A_FOC1A	0x08
#define   TCCR1A_FOC1B	0x04
#define   TCCR1A_WGM11	0x02
#define   TCCR1A_WGM10	0x01
#define TCCR1B		0x4e
#define   TCCR1B_ICNC1	0x80
#define   TCCR1B_ICES1	0x40
#define   TCCR1B_WGM13	0x10
#define   TCCR1B_WGM12	0x08
#define   TCCR1B_CS12	0x04
#define   TCCR1B_CS11	0x02
#define   TCCR1B_CS10	0x01
#define TCNT1H		0x4d
#define TCNT1L		0x4c
#define TCNT1		0x4c
#define OCR1AH		0x4b
#define OCR1AL		0x4a
#define OCR1A		0x4a
#define OCR1BH		0x49
#define OCR1BL		0x48
#define OCR1B		0x48
#define ICR1H		0x47
#define ICR1L		0x46
#define ICR1		0x46
#define TCCR2		0x45
#define   TCCR2_FOC2	0x80
#define   TCCR2_WGM20	0x40
#define   TCCR2_COM21	0x20
#define   TCCR2_COM20	0x10
#define   TCCR2_WGM21	0x08
#define   TCCR2_CS22	0x04
#define   TCCR2_CS21	0x02
#define   TCCR2_CS20	0x01
#define TCNT2		0x44
#define OCR2		0x43
#define ASSR		0x42
#define   ASSR_AS2	0x08
#define   ASSR_TCN2UB	0x04
#define   ASSR_OCR2UB	0x02
#define   ASSR_TCR2UB	0x01
#define WDTCR		0x41
#define   WDTCR_WDCE	0x10
#define   WDTCR_WDE	0x08
#define   WDTCR_WDP2	0x04
#define   WDTCR_WDP1	0x02
#define   WDTCR_WDP0	0x01
#define UBRRH		0x40
#define   UBRRH_URSEL	0x80
#define   UBRRH_UBRRMSK	0x0f
#define   UBRRH_UBRR11	0x08
#define   UBRRH_UBRR10	0x04
#define   UBRRH_UBRR9	0x02
#define   UBRRH_UBRR8	0x01
#define UCSRC		0x40
#define   UCSRC_URSEL	0x80
#define   UCSRC_UMSEL	0x40
#define   UCSRC_UPM1	0x20
#define   UCSRC_UPM0	0x10
#define   UCSRC_USBS	0x08
#define   UCSRC_UCSZ1	0x04
#define   UCSRC_UCSZ0	0x02
#define   UCSRC_UCPOL	0x01
#define EEARH		0x3f
#define EEARL		0x3e
#define EEAR		0x3e
#define EEDR		0x3d
#define EECR		0x3c
#define   EECR_EERIE	0x08
#define   EECR_EEMWE	0x04
#define   EECR_EEWE	0x02
#define   EECR_EERE	0x01
#define PORTB		0x38
#define DDRB		0x37
#define PINB		0x36
#define PORTC		0x35
#define DDRC		0x34
#define PINC		0x33
#define PORTD		0x32
#define DDRD		0x31
#define PIND		0x30
#define SPDR		0x2f
#define SPSR		0x2e
#define   SPSR_SPIF	0x80
#define   SPSR_WCOL	0x40
#define   SPSR_SPI2X	0x01
#define SPCR		0x2d
#define   SPCR_SPIE	0x80
#define   SPCR_SPE	0x40
#define   SPCR_DORD	0x20
#define   SPCR_MSTR	0x10
#define   SPCR_CPOL	0x08
#define   SPCR_CPHA	0x04
#define   SPCR_SPR1	0x02
#define   SPCR_SPR0	0x01
#define UDR		0x2c
#define UCSRA		0x2b
#define   UCSRA_RXC	0x80
#define   UCSRA_TXC	0x40
#define   UCSRA_UDRE	0x20
#define   UCSRA_FE	0x10
#define   UCSRA_DOR	0x08
#define   UCSRA_PE	0x04
#define   UCSRA_U2X	0x02
#define   UCSRA_MPCM	0x01
#define UCSRB		0x2a
#define   UCSRB_RXCIE	0x80
#define   UCSRB_TXCIE	0x40
#define   UCSRB_UDRIE	0x20
#define   UCSRB_RXEN	0x10
#define   UCSRB_TXEN	0x08
#define   UCSRB_UCSZ2	0x04
#define   UCSRB_RXB8	0x02
#define   UCSRB_TXB8	0x01
#define UBRRL		0x29
#define ACSR		0x28
#define   ACSR_ACD	0x80
#define   ACSR_ACBG	0x40
#define   ACSR_ACO	0x20
#define   ACSR_ACI	0x10
#define   ACSR_ACIE	0x08
#define   ACSR_ACIC	0x04
#define   ACSR_ACIS1	0x02
#define   ACSR_ACIS0	0x01
#define ADMUX		0x27
#define   ADMUX_REFS1	0x80
#define   ADMUX_REFS0	0x40
#define   ADMUX_ADLAR	0x20
#define   ADMUX_MUX3	0x08
#define   ADMUX_MUX2	0x04
#define   ADMUX_MUX1	0x02
#define   ADMUX_MUX0	0x01
#define ADCSRA		0x26
#define   ADCSRA_ADEN	0x80
#define   ADCSRA_ADSC	0x40
#define   ADCSRA_ADFR	0x20
#define   ADCSRA_ADIF	0x10
#define   ADCSRA_ADIE	0x08
#define   ADCSRA_ADPS2	0x04
#define   ADCSRA_ADPS1	0x02
#define   ADCSRA_ADPS0	0x01
#define ADCH		0x25
#define ADCL		0x24
#define ADC		0x24
#define TWDR		0x23
#define TWAR		0x22
#define   TWAR_TWA6	0x80
#define   TWAR_TWA5	0x40
#define   TWAR_TWA4	0x20
#define   TWAR_TWA3	0x10
#define   TWAR_TWA2	0x08
#define   TWAR_TWA1	0x04
#define   TWAR_TWA0	0x02
#define   TWAR_TWGCE	0x01
#define TWSR		0x21
#define   TWSR_TWS7	0x80
#define   TWSR_TWS6	0x40
#define   TWSR_TWS5	0x20
#define   TWSR_TWS4	0x10
#define   TWSR_TWS3	0x08
#define   TWSR_TWPS1	0x02
#define   TWSR_TWPS0	0x01
#define TWBR		0x20
