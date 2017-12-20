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
      09/03/17    Sophia Liu    Edited comments
*/

#ifndef  __GENERAL_H__
    #define  __GENERAL_H__

// addresses
#define VRAM_ADDRESS       0x140000 // vram start address
#define VRAM_ADDRESS_END   0x17ffff // vram end address

// PIO addresses
#define ROT_ADDRESS        0x1d10e0 // rotary pio address

// analog PIO addresses
#define AUTO_TRIGGER_PIO   0x1d1150 // 1 bit data, 1 for auto triggering,
                                    //    0 for no auto triggering
#define TRIGGER_ENABLE_PIO 0x1d1140 // 1 bit data, 1 for trigger enable,
                                    //    0 if not enabled
#define TRIGGER_SLOPE_PIO  0x1d1130 // 1 bit data, 1 for negative slope,
                                    //    0 for positive slope
#define SAMPLE_DELAY_PIO   0x1d1120 // 16 bit data, sample delay (in # samples)
#define TRIGGER_LEVEL_PIO  0x1d1110 // 8 bit data for trigger level
#define SAMPLE_RATE_PIO    0x1d1100 // 19 bit data for sample rate (samples/sec)

// PIO addresses - FIFO
#define DATA_READY_PIO     0x1d10f0 // data ready signal, read clock input for fifo
#define FIFO_DATA_PIO      0x1d10c0 // 8 bit sample currently read from fifo
#define FIFO_FULL_PIO      0x1d10d0 // 1 bit, 1 if fifo full, 0 if not full

#define WD_PIO             0x1d10b0 // 1 bit output for watchdog timer

// other constants
#define VRAM_WIDTH    512           // length of VRAM row 
#define NUM_SAMPLES   512           // number of samples in fifo
#define CLOCK_FREQ    24000000      // clock frequency, 24 MHz

#define ROT_IRQ       0             // rotary interrupt number

#define  PTRNL       0              // null pointer reference
#define  FALSE       0
#define  TRUE        !FALSE

#endif
