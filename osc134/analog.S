# ###########################################################################
#                                                                           #
#                   Analog functions for digital oscilloscope               #
#                                   EE 52                                   #
#                                                                           #
#                                                                           #
# ###########################################################################
# Name of file: analog.s
# Description: Analog functions for digital oscilloscope
# Public functions:
#    int set_sample_rate(long int samples_per_sec): Sets the sample rate
#        to the passed value (in samples per second). The number of samples
#        that will be taken at that sample rate is returned.
#    void set_trigger(int level, int slope): Sets the trigger level to the
#        first argument and the slope to the second argument
#        (1 for negative slope, 0 for positive slope). The trigger level is
#        passed as a value between 0 and 127, with 0 indicating the lowest
#        (most negative for bipolar input) trigger input level and 127
#        indicating the highest (most positive) trigger input level.
#    void set_delay(long int delay): Sets the trigger delay to the passed value.
#    void start_sample(int auto_trigger): Immediately starts sampling data.
#        If the argument is FALSE, then the sampling should start when there
#        is a trigger event. If the argument is TRUE, then the sampling should
#        start when there is a trigger event or when the automatic trigger
#        timeout occurs, whichever is first.
#    unsigned char far *sample_done(void): Returns NULL if not done with the
#        current sample and a pointer to the sampled data otherwise. The
#        sampled data should contain the number of data points previously
#        returned by the set_sample_rate function. The function should only
#        return a non-NULL pointer once for each call to the start_sample function.
# Local functions:
# Input:    None
# Output:   None
#
# Revision History: 06/24/17 Sophia Liu     initial revision

# inc header files for constants
# inc "scopedef.h"
#include "general.h"

# set sample rate
#
#
# Description: Sets the sample rate to the passed argument, in samples per second.
#     Returns the number of samples that will be taken at that sample rate.
#
# Operation: Divides the clock frequency by the rate to get the number of
#     clocks between samples. Writes the sample number to the sample rate pio
#     and returns the sample number.
#
# Arguments:         Long int samples_per_sec
# Return Values:     int num_samples: number of samples that will be taken
#
# Local Variables:   None.
# Shared Variables:
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed:
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global set_sample_rate
.type set_sample_rate, @function # RATE OR NUM ON PIO? TODO
set_sample_rate:
movhi r8, %hi(CLOCK_FREQ)
ori r8, r8, %lo(CLOCK_FREQ) # store 32 bit clock frequency constant into register
divu r9 , r8, r4         # divide clock frequency by sample rate for sample number
                         # store result in r2 to return
mov r2, r9

movia r8, SAMPLE_RATE_PIO # get address of sample rate pio
stw r2, 0(r8)            # drive sample rate argument on sample rate pio output (byte?)

ret

# set trigger
#
#
# Description: Takes two arguments for trigger level and slope. The trigger
#     level is between 0 (lowest trigger input level) and 127 (highest trigger
#     input level), and the slope is 1 (negative slope) or 0 (positive slope).
#     Sets the trigger level and slope to the passed arguments.
#
# Operation: Writes to the trigger level and slope pio cores.
#
# Arguments:         int level, int slope
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  None.
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed:
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global set_trigger
.type set_trigger, @function
set_trigger:
movia r8, TRIGGER_LEVEL_PIO
stb r4, 0(r8)    # write level argument to trigger level pio

movia r8, TRIGGER_SLOPE_PIO
stb r5, 0(r8)    # write slope argument to trigger slope pio

ret

# set delay
#
#
# Description: Takes one argument, the delay in samples. Sets the trigger
#     delay to the passed value (in samples)
#
# Operation: Writes to the sample delay pio.
#
# Arguments:         long int delay
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  None.
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed:
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global set_delay
.type set_delay, @function
set_delay:
movia r8, SAMPLE_DELAY_PIO
stw r4, 0(r8)    # write delay argument to delay pio core
# convert delay to samples? DELAY SIZE?
ret

# start sample
#
#
# Description: Starts sampling data. Takes one argument for auto triggering.
#    If the argument is false, sampling starts when there is a trigger event.
#    If the argument is true, the sampling starts when there is a trigger event
#    or when the automatic trigger timeout occurs (whichever is first)
#
# Operation:
#
# Arguments:         int auto_trigger
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  None.
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed:
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global start_sample
.type start_sample, @function
start_sample:
# clear fifo/fifo full flag?
movia r8, fifo_full_flag
movi r9, FALSE
stb r9, 0(r8)                 # store false in fifo full flag

movia r8, AUTO_TRIGGER_PIO
stb r4, 0(r8)                 # write auto triggering argument to pio core

movia r8, TRIGGER_ENABLE_PIO
movi r9, TRUE
stb r9, 0(r8)     # enable triggering by writing to trigger enable pio

movia r8, sample_done_flag
movi r9, FALSE
stb r9, 0(r8)     # reset sample done flag - only after each start_sample call
ret

# sample done
#
#
# Description: Returns NULL if not done with the current sample and a pointer
#     to the sampled data otherwise. The sampled data contains the number of
#     data points previously returned by the set_sample_rate functions. Only
#     returns a non-NULL pointer once for each call to the start_sample function.
#
# Operation:
#
# Arguments:         None.
# Return Values:
#
# Local Variables:   None.
# Shared Variables:  None.
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed:
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global sample_done
.type sample_done, @function
sample_done:
movi r8, TRUE

movia r9, sample_done_flag
ldb r10, 0(r9)           # get sample done flag from shared variable
beq r10, r8, return_null_ # If the flag is true, the sample is already done,
                         #     return null.
# bne r10, r8, check_fifo # Else flag is false, check if fifo is full

check_fifo:
movia r9, fifo_full_flag
ldb r10, 0(r9)           # get fifo full flag from shared variable
bne r10, r8, return_null_ # If the flag is not true, fifo is not full,
                         #     return null.
# beq r10, r8, return_pointer # Else flag is true, fifo is full, return pointer

return_pointer: # copy fifo into data buffer
movia r8, DATA_READY_PIO  # get address for fifo read clock
movia r10, FIFO_DATA_PIO  # address to read fifo data from
movia r11, data_buffer    # get address of data buffer shared variable
addi r13, r11, NUM_SAMPLES # get address of last sample in data buffer

read_fifo_loop:
ldb r12, 0(r10)            # read current sample from fifo
stb r12, 0(r11)            # store sample in data buffer
addi r11, r11, 1           # go to next address in data buffer

bge r11, r13, got_sample   # if at address of last sample in data buffer,
                           #     finished reading samples from fifo
# blt r11, r13, read_fifo_loop_next # otherwise, continue loop

read_fifo_loop_next:       # clock out next sample from fifo
movi r9, 0
stb r9, 0(r8) # TODO unnecessary?
movi r9, 1
stb r9, 0(r8)
movi r9, 0
stb r9, 0(r8)              # pulse read clock for fifo
jmpi read_fifo_loop        # go back to top of loop to read next sample

got_sample:
movia r8, sample_done_flag
movi r9, TRUE
stb r9, 0(r8)            # set sample done flag to true - completed sample

movia r2, data_buffer    # return pointer to sampled data
ret

return_null_:
movi r2, PTRNL     # return null?
ret

# analog eh
#
#
# Description: Handles interrupts for the fifo full interrupt.
#
# Operation:
#
# Arguments:         None.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  None.
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed:
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global fifo_full_eh
.type fifo_full_eh, @function
fifo_full_eh:
addi sp, sp, -8        # adjust stack pointer
stw ra, 4(sp)          # store return address
stw r28, 0(sp)         # store frame pointer

# read from fifo pio
movia r8, FIFO_FULL_PIO
ldb r9, 12(r8)         # read from edge capture register of fifo full pio

# clear pio?
movi r10, 0
stb r10, 0(r8)

movia r10, fifo_full_flag
stb r9, 0(r10)         # set sample done flag to edge capture register value

movi r8, 0x1
stbio r8, 8(r9)        # interrupt mask register, enable interrupts? in sample done?

# other settings?

ldw r28, 0(sp)         # load frame pointer
ldw ra, 4(sp)          # load return address
addi sp, sp, 8         # adjust stack pointer
ret

# init analog
#
#
# Description: Initializes variables and interrupts used for analog functions.
#
# Operation:
#
# Arguments:         None.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  None.
# Global Variables:  None.
#
# Input:             None.
# Output:            None.
#
# Error Handling:    None.
# Algorithms:        None.
# Data Structures:   None.
#
# Known Bugs:        None.
# Limitations:       None.
# Registers changed: r8, r9
# Stack depth:
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global init_analog
.type init_analog, @function
init_analog:
addi sp, sp, -8        # adjust stack pointer
stw ra, 0(sp)          # store return address
stw r28, 4(sp)         # store frame pointer
# clear fifo?
# set_flags_analog:
movia r8, fifo_full_flag
movi r9, FALSE
stb r9, 0(r8)            # set fifo full flag to false

movia r8, sample_done_flag
movi r9, FALSE
stb r9, 0(r8)            # set sample done flag to false (?)

init_pios:
movia r8, TRIGGER_ENABLE_PIO
movi r9, FALSE
stb r9, 0(r8)    # disable triggering by writing to trigger enable pio

init_fifo_int:
movui r4, 1 # FIFO_FULL_IRQ      # arguments for alt_irq_register
movui r5, 0
movia r6, fifo_full_eh
call alt_irq_register        # register fifo full interrupt

movia r8, FIFO_FULL_PIO     # get pio core address
#movi r9, 0x0
#stbio r9, 4(r8)   # direction register, set to input

movi r9, 0x0
stbio r9, 12(r8)   # edge capture register, clear all

movi r9, 0x1
stbio r9, 8(r8)    # interrupt mask register, enable interrupts

ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8        # adjust stack pointer
ret

# data section
.section .data
.align 4
fifo_full_flag: .byte 0x0    # 1 byte boolean. TRUE if the fifo is full,
                             #     FALSE otherwise.

sample_done_flag:  .byte 0x0 # 1 byte boolean. TRUE if the sample is done,
                             #     FALSE otherwise.

data_buffer: .skip NUM_SAMPLES  # buffer for sampled data from fifo buffer
