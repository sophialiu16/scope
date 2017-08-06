/****************************************************************************/
/*                                                                          */
/*                                GENERAL.H                                 */
/*                           General Definitions                            */
/*                               Include File                               */
/*                       Digital Oscilloscope Project                       */
/*                                 EE/CS 52                                 */
/*                                                                          */
/****************************************************************************/

/*
   This file contains definitions for the Digital Oscilloscope
   project.  This includes addresses and other constants specific to this scope.


   Revision History:
      07/16/17    Sophia Liu    Initial revision
*/

#ifndef  __GENERAL_H__
    #define  __GENERAL_H__

// addresses
#define VRAM_ADDRESS       0x140000        // vram start address
#define VRAM_ADDRESS_END   0x17ffff        // vram end address

// PIO addresses
#define ROT_ADDRESS        0x1d10c0        // rotary pio

// analog PIO addresses
#define AUTO_TRIGGER_PIO   0x1d1130 // 1 bit data, 1 for auto triggering, 0 for no auto triggering
#define TRIGGER_ENABLE_PIO 0x1d1120 // 1 bit data, 1 for trigger enable, 0 if not enabled
#define TRIGGER_SLOPE_PIO  0x1d1110 // 1 bit data, 1 for negative slope, 0 for positive slope
#define SAMPLE_DELAY_PIO   0x1d1100 // 16 bits data, sample delay (in # samples)
#define TRIGGER_LEVEL_PIO  0x1d10f0 // 8 bits data
#define SAMPLE_RATE_PIO    0x1d10e0 // 19 bits data

// PIO addresses - FIFO
#define DATA_READY_PIO     0x1d10d0 // data ready signal, read clock for fifo
#define FIFO_DATA_PIO      0x1d10a0 // 8 bit sample currently read from fifo
#define FIFO_FULL_PIO      0x1d10b0 // 1 if fifo full, 0 if not full TODO level/edge interrupt

// other constants
#define NUM_SAMPLES   512      // number of samples in fifo
#define CLOCK_FREQ    24000000 // clock frequency, 24 MHz

// interrupt definitions
#define ROT_IRQ       0

#define  PTRNL       0 
#define  FALSE       0
#define  TRUE        !FALSE

#endif
