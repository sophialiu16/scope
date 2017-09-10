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
# Local functions: None.
# Input:    None.
# Output:   None.
#
# Revision History: 06/24/17 Sophia Liu     initial revision
#                   09/10/17 Sophia Liu     edited comments

# inc header files for constants
#include "general.h"

# set sample rate
#
#
# Description: Sets the sample rate to the passed argument, in samples per second.
#     Returns the number of samples that will be taken at that sample rate.
#
# Operation: Divides the clock frequency by the rate to get the number of
#     clocks between samples. Writes the sample number to the sample rate pio.
#     Returns the sample number.
#
# Arguments:         Long int samples_per_sec (r4) - 19-bit value for the
#                    number of samples per second.
#
# Return Values:     int num_samples: number of samples that will be taken at
#                    the clock rate constant.
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
# Registers changed: r8. r9. r2.
# Stack depth:       0 words.
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global set_sample_rate
.type set_sample_rate, @function
set_sample_rate:
movhi r8, %hi(CLOCK_FREQ)   # store 32 bit clock frequency constant into register
ori r8, r8, %lo(CLOCK_FREQ)
divu r9, r8, r4            # divide clock frequency by sample rate for sample number

movia r8, SAMPLE_RATE_PIO   # get address of sample rate pio
stwio r9, 0(r8)             # drive sample number on sample rate pio output

movi r2, NUM_SAMPLES        # return sample size constant (have a set fifo size)
ret

# set trigger
#
#
# Description: Takes two arguments for trigger level and slope. The trigger
#     level is between 0 (lowest trigger input level) and 127 (highest trigger
#     input level), and the slope is 1 (negative slope) or 0 (positive slope).
#     Sets the trigger level and slope pios to the passed arguments.
#
# Operation: Scales the trigger level argument to match the analog input
#    signal and writes the trigger level and slope arguments to the
#    corresponding pio cores.
#
# Arguments: int level (r4) - 7-bit value for the trigger level,
#                with 0 being the lowest trigger input level and 127 being the
#                highest trigger input level.
#            int slope (r5) - 1-bit value for the trigger slope, with
#                1 being a negative slope and 0 being the positive slope.
#
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
# Registers changed: r4, r8.
# Stack depth:       0 words.
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global set_trigger
.type set_trigger, @function
set_trigger:
movia r8, TRIGGER_LEVEL_PIO # get trigger level pio address
muli r4, r4, 2              # multiply by 2 to get a range of 0 to 254,
                            #     to match 8 bit ADC data/signal range
stbio r4, 0(r8)             # write level argument to trigger level pio

movia r8, TRIGGER_SLOPE_PIO # get trigger slope pio address
stbio r5, 0(r8)             # write slope argument to trigger slope pio

ret

# set delay
#
#
# Description: Takes one argument, the delay in samples. Sets the trigger
#     delay to the passed value (in samples)
#
# Operation: Writes the sample delay argument to the corresponding pio.
#
# Arguments:         long int delay- 16-bit value for the delay (in samples).
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
# Registers changed: r8.
# Stack depth:       0 words.
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global set_delay
.type set_delay, @function
set_delay:
movia r8, SAMPLE_DELAY_PIO    # get the sample delay pio address
stwio r4, 0(r8)               # write delay argument to delay pio core

ret

# start sample
#
#
# Description: Starts sampling data. Takes one argument for auto triggering.
#    If the argument is false, sampling starts when there is a trigger event.
#    If the argument is true, the sampling starts when there is a trigger event
#    or when the automatic trigger timeout occurs (whichever is first)
#
# Operation: Writes the auto trigger argument to the auto trigger pio, and
#     sets the trigger enable pio high to start sampling data. Sets the sample
#     done shared variable to false to indicate that no trigger has occured yet.
#
# Arguments:         int auto_trigger - 1-bit value for auto-triggering.
#                        FALSE if auto-triggering is not enabled, TRUE
#                        if it is enabled.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  sample_done_flag(W) - 1 byte boolean flag. TRUE if the
#                        sample has been taken, FALSE otherwise.
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
# Registers changed: r8, r9.
# Stack depth:       0 words.
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global start_sample
.type start_sample, @function
start_sample:
movia r8, AUTO_TRIGGER_PIO      # get auto trigger pio address
stbio r4, 0(r8)                 # write auto triggering argument to pio core

# enable triggering- pulse trigger enable pio and set high
movia r8, TRIGGER_ENABLE_PIO    # get trigger enable pio address
movi r9, FALSE
stbio r9, 0(r8)                 # set trigger enable pio low

movi r9, TRUE
stbio r9, 0(r8)                 # set trigger enable pio high

# reset sample done flag - only after each start_sample call
movia r8, sample_done_flag    # get sample done flag shared variable address
movi r9, FALSE
stbio r9, 0(r8)               # set the sample done flag to false
ret

# sample done
#
#
# Description: Returns NULL if not done with the current sample and a pointer
#     to the sampled data otherwise. The sampled data contains the number of
#     data points previously returned by the set_sample_rate functions. Only
#     returns a non-NULL pointer once for each call to the start_sample function.
#
# Operation: Checks the sample done flag and returns null if the sample is
#     already completed. Checks the fifo full pio and returns null if the fifo
#     is not full. Otherwise, the fifo is clocked out into the data buffer
#     shared variable,the sample done flag is set to TRUE, trigger enabling is
#     set to FALSE, and a pointer to the data buffer is returned.
#
# Arguments:         None.
# Return Values:     sampled data - 32-bit pointer to the sampled data. Returns
#                        NULL if not done with the current sample. Only
#                        returns a non-NULL pointer once for each call to the
#                        start_sample function.
#
# Local Variables:   None.
# Shared Variables:  sample_done_flag(R/W) - 1 byte boolean flag. TRUE if the
#                        sample has been taken, FALSE otherwise.
#                    data_buffer(W) - NUM_SAMPLES (number of samples taken)
#                        bytes, buffer for sampled data from the fifo buffer.
#
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
# Registers changed: r2, r8, r9, r10, r11, r12, r13.
# Stack depth:       0 words.
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global sample_done
.type sample_done, @function
sample_done:
movi r8, TRUE              # store true to compare to sample done flag

movia r9, sample_done_flag # get sample dong flag shared variable address
ldb r10, 0(r9)             # load sample done flag value from shared variable
beq r10, r8, return_null_  # If the flag is true, the sample is already done,
                           #     return null.
# bne r10, r8, check_fifo  # Else flag is false, check if fifo is full

check_fifo:
movia r9, FIFO_FULL_PIO    # get address of the fifo full pio
ldbio r10, 0(r9)           # check to see if the fifo is full
bne r10, r8, return_null_  # If the flag is not true, fifo is not full,
                           #     return null.
# beq r10, r8, return_pointer # Else flag is true, fifo is full, return pointer

return_pointer:            # copy fifo sample buffer into data buffer
movia r8, DATA_READY_PIO   # get address for fifo read clock input pio
movia r10, FIFO_DATA_PIO   # get address to read fifo data from
movia r11, data_buffer     # get address of data buffer shared variable
addi r13, r11, NUM_SAMPLES # get address of last sample in data buffer

# loop to clock out fifo buffer
read_fifo_loop:
ldbio r12, 0(r10)          # load current sample from fifo
stb r12, 0(r11)            # store sample in data buffer
addi r11, r11, 1           # go to next address in data buffer

bge r11, r13, got_sample   # if at address of last sample in data buffer,
                           #     finished reading samples from fifo
# blt r11, r13, read_fifo_loop_next # otherwise, continue loop

read_fifo_loop_next:       # clock out next sample from fifo
movi r9, 0
stbio r9, 0(r8)
movi r9, 1
stbio r9, 0(r8)
movi r9, 0
stbio r9, 0(r8)            # pulse read clock for fifo
jmpi read_fifo_loop        # go back to top of loop to read the next sample

got_sample:
movia r8, sample_done_flag   # get address of sample done flag shared variable
movi r9, TRUE
stb r9, 0(r8)                # set sample done flag to true - completed sample

movia r8, TRIGGER_ENABLE_PIO # get address of trigger enable pio
movi r9, FALSE
stbio r9, 0(r8)              # stop sampling, set trigger enable to false

movia r2, data_buffer        # return pointer to sampled data
ret

return_null_:
movi r2, PTRNL               # return null
ret

# init analog
#
#
# Description: Initializes variables used for analog functions.
#
# Operation: Initializes the sample done flag to false (sample has not been
#    completed) and sets the trigger enable pio to false (triggering not
#    enabled yet).
#
# Arguments:         None.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  sample_done_flag(W) - 1 byte boolean flag. TRUE if the
#                        sample has been taken, FALSE otherwise.
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
# Registers changed: r8, r9.
# Stack depth:       2 words.
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

movia r8, sample_done_flag   # get address of sample done flag shared variable
movi r9, FALSE
stb r9, 0(r8)                # set sample done flag to false

init_pios:
# disable triggering
movia r8, TRIGGER_ENABLE_PIO # get address of the trigger enable pio
movi r9, FALSE
stbio r9, 0(r8)              # set trigger enable pio to false


ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8         # adjust stack pointer
ret

# data section
.section .data
.align 4
sample_done_flag:  .byte 0x0   # 1 byte boolean flag. TRUE if the sample
                               # has been taken, FALSE otherwise.

data_buffer: .skip NUM_SAMPLES # NUM_SAMPLES (number of samples taken) bytes,
                               # buffer for sampled data from the fifo buffer.
