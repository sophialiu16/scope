

# ###########################################################################
#                                                                           #
#                  Keypad functions for digital oscilloscope                #
#                                   EE 52                                   #
#                                                                           #
#                                                                           #
# ###########################################################################
# Name of file: keypad.s
# Description:
# Public functions:
# Local functions:
# Input:    None
# Output:   None
#
# Revision History: 06/06/17 Sophia Liu     initial revision

#include "interfac.h"
#include "general.h"
 # .equ ROT_ADDRESS,0x00151010
 # .equ KEY_ILLEGAL, 0

.section .text

# KeyAvailable
#
#
# Description: Returns
#
# Operation: Returns TRUE (non-zero) if there is a valid key ready to be
#     processed and FALSE (zero) otherwise. Returns false after getKey is called
#
# Arguments:         None.
# Return Values:     Int r2 , Non-zero (True) or zero (false), whether or not
#                        there is a valid key ready to be processed
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
# Revision History: 06/06/17   Sophia Liu      initial revision
.align 4
.global key_available
.type key_available, @function
key_available:
addi sp, sp, -8        # adjust stack pointer
stw ra, 0(sp)          # store return address
stw r28, 4(sp)         # store frame pointer

movia r8, key_pressed      # get address of key_pressed
ldbu r9, 0(r8)             # load value in key_pressed
cmpnei r2, r9, KEY_ILLEGAL # check if current key value is illegal key
                           # r2 = 0 if is illegal key, = 1 if not illegal

ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8         # adjust stack pointer

ret

# GetKey
#
#
# Description:       Returns the keycode for the debounced key.
#
# Operation:         Gets key_pressed and does not return until there is a valid key.
#                        never returns KEY_ILLEGAL.
#
# Arguments:         None.
# Return Values:     Unsigned char r2, the keycode for the debounced key.
#                       Never returns KEY_ILLEGAL
#
# Local Variables:   None.
# Shared Variables:  key_pressed
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
# Revision History: 06/06/17   Sophia Liu      initial revision
.align 4
.global getkey
.type getkey, @function
getkey:
addi sp, sp, -8        # adjust stack pointer
stw ra, 0(sp)          # store return address
stw r28, 4(sp)         # store frame pointer

movia r9, key_pressed  # get address of key_pressed

get_key_loop:
ldw r2, 0(r9)             # load value in key_pressed
cmpeqi r10, r2, KEY_ILLEGAL # check if current key value is illegal key
bne r0, r10, get_key_loop   # if current key is illegal key, loop back and
                           #     check again
# beq r0, r10, have_key     # else key is not illegal key, can return

have_key:
movi r10, KEY_ILLEGAL
stw r10, 0(r9)              # clear key_pressed

ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8         # adjust stack pointer

ret                        # have key, return

# keypadInterruptHandler
#
#
# Description:       Interrupt handler for the keypad
#
# Operation:         Reads in the keycode value and saves it in key_pressed
#
# Arguments:         None.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  key_pressed
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
# Revision History: 06/06/17   Sophia Liu      initial revision
.align 4
.global keypadInterruptHandler
.type keypadInterruptHandler, @function
keypadInterruptHandler:
addi sp, sp, -8        # adjust stack pointer
stw ra, 4(sp)          # store return address
stw r28, 0(sp)         # store frame pointer


load_key:
movia r9, ROT_ADDRESS       # read in pio core address
ldbio r10, 12(r9)


cmpeqi r8, r10, KEY_ILLEGAL 				# check if current key value is illegal key
bne r0, r8, endKeypadInterruptHandler   # if current key is illegal key, end


movia r8, key_pressed    	# get address of key_pressed
stw r10, 0(r8)           	# store pio data value from edge register in key_pressed


movui r8, 0
stbio r8, 12(r9)   # edge capture register, clear all

movi r8, 0x1f
stbio r8, 8(r9)    # interrupt mask register, enable interrupts

endKeypadInterruptHandler:
ldw r28, 0(sp)
ldw ra, 4(sp)
addi sp, sp, 8

ret

# InitKeypad
#
#
# Description: Initializes keypad interrupts
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
# Revision History: 06/06/17   Sophia Liu      initial revision
.align 4
.global initKeypad
.type initKeypad, @function
initKeypad:
addi sp, sp, -8        # adjust stack pointer
stw ra, 0(sp)          # store return address
stw r28, 4(sp)         # store frame pointer

movia r8, ROT_ADDRESS     # get pio core address
movi r9, 0
stbio r9, 8(r8)    # interrupt mask register, disable interrupts

movui r4, 0            # arguments for alt_ic_isr_register
movui r5, 0
movia r6, keypadInterruptHandler
call alt_irq_register

# movui r7, 0
                      # save last argument on the stack
# addi sp, sp, -8       # adjust stack pointer
# stw ra, 4(sp)         # store return argument
# stw r0, 0(sp)         # store argument


# call alt_ic_isr_register


                     # pop off stack
# ldw ra, 4(sp)        # pop off return address
# addi sp, sp, 8       # adjust stack pointer

movia r8, key_pressed # initialize keypad with illegal key
movi r9, KEY_ILLEGAL
stw r9, 0(r8)

initInterrupts:
movia r8, ROT_ADDRESS     # get pio core address
movi r9, 0x0
stbio r9, 4(r8)   # direction register, set to input

movi r9, 0x0
stbio r9, 12(r8)   # edge capture register, clear all

movi r9, 0x1f
stbio r9, 8(r8)    # interrupt mask register, enable interrupts

ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8        # adjust stack pointer
ret

# data section
.section .data
.align 4
key_pressed: .word 0x0         # 1 word unsigned int, contains current debounced key
