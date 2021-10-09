# libavr - Library of useful functions for AVR-based processors.

This is a library of functions for Atmel (now Microchip) processors in
the AVR family, such as the ATmega8 and ATmega328p as made famous by
the ubiquitous Arduino.
This is in addition to, and complementing the functions provided by the
main AVR library (AVRLIB).
The key components are the RS232 ring buffers and the bootstrap mechanism.

## Bootstrap

The Bootstrap function provides a very simple (but effective) mechanism
for being able to update the flash within the chip over the RS232 line.
The code occupies about 230 words (460 bytes) at high memory, and once
invoked, will disable interrupts, configure the serial port if necessary,
and begin communicating with the programming software.
For more information on the function, look at the source code and
especially the comments in _bootstrap.s_.

## Serial Ring Buffers

The serial I/O is handled by two 32-character ring buffers, consuming
64 bytes of RAM, as well as four bytes to manage the two head and two
tail pointers.
In a nutshell, without getting into the workings of
[ring buffers](https://en.wikipedia.org/wiki/Circular_buffer),
the idea is that you try to minimize the handshaking between
the main code and the interrupt service routine.
On output, the code in _sioput.c_ is used to check if there is any space
in the ring buffer.
If there is, it just adds the character to the buffer and advances the
head pointer.
Note that only the *sio\_enqueue()* function can update the head pointer
so there is no danger of a collision.
It also enables transmit interrupts, just in case they've been turned off.
That code is in _serinten.S_.

When an interrupt occurs on the UDRE (USART Data Register Empty) vector,
it should call *sio\_out()* which is in _sioint.S_.
The ISR will pull the next character off the ring buffer, send it out
on the serial port, advance the tail pointer (of which it has exclusive
ownership), and if the ring buffer is now empty, it will disable TX
interrupts.

In this way, it is possible for the character output code to get up to
32 characters into the buffer, before it fills up.
If the buffer fills up, the *sio\_enqueue()* function can either wait
for the buffer to drain, or return unsuccessfully, immediately.
There is also a handy *sio\_putc()* function which calls *sio\_enqueue()*.
It will also convert a newline (\n) to a CRLF sequence (\r\n).

On the input side, the ISR for RXC (USART Rx Complete) should be wired
to *sio\_in()* which is also in _sioint.S_.
This function will attempt to place the received character into the
receive ring.
If the ring is full, it will silently drop the character.
On the receive side, there is a matching function (*sio\_dequeue()*),
defined in _sioget.c_ which will attempt to remove a character from the
input ring.
Again, the *blockf* argument specifies whether or not the function should
wait until there is a character, or return immediately.
The *sio\_iqueue\_empty()* can be called to check if the input queue is
empty or not.
As before, there is a helper function to couple this function with the
AVRLIB I/O library.
That function is *sio_getc()* and will block until a character is
available on the serial line.

These two helper functions can be added to the AVRLIB I/O subsystem by
making the following call during code initialization:

    (void )fdevopen(sio_putc, sio_getc);
