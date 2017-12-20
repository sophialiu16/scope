# ###########################################################################
#                                                                           #
#                  Keypad functions for digital oscilloscope                #
#                                   EE 52                                   #
#                                                                           #
#                                                                           #
# ###########################################################################
# Name of file: keypad.s
# Description: Keypad functions for digital oscilloscope. Used to get the
#              current key value and handle keypad interrupts. Rotary encoders
#              were implemented, so "keypad" often refers to the rotary encoders.
# Public functions:
#     unsigned char key_available(void): Whether or not there is a valid key
#         value. Returns TRUE (non-zero) if there is a valid key ready to be
#         processed and FALSE (zero) otherwise.
#     int getkey(void): Returns the keycode (found in interfac.h) for the
#         debounced key. This value is never KEY_ILLEGAL. The function does
#         not return until it has a valid key.
#     void initKeypad(void): Initializes keypad interrupts and variables.
#         Registers keypad event handler, initializes key_pressed with
#         KEY_ILLEGAL, initializes rotary PIO and enables interrupts.
#         Must be called before using the keypad.
#
# Local functions:
#     keypadInterruptHandler: Event handler for the keypad. Stores the current
#         valid key value in key_pressed.
#
# Input:    None
# Output:   None
#
# Revision History: 06/06/17 Sophia Liu     initial revision
#                   12/2017  Sophia Liu     edited comments

#include "interfac.h"
#include "general.h"

.section .text

# Key_available
#
#
# Description: Whether or not there is a valid key value. Returns TRUE
#              (non-zero) if there is a valid key ready to be processed and
#              FALSE (zero) otherwise.
#
# Operation: Reads current key_pressed value. Returns TRUE (non-zero) if there
#            is a valid key ready to be processed and FALSE (zero) otherwise.
#
# Arguments:         None.
# Return Values:     key is available - unsigned char, TRUE (non-zero) if
#                        current key value is valid or FALSE (zero) if it
#                        is not; whether or not there is a valid key ready
#                        to be processed.
#
# Local Variables:   None.
# Shared Variables:  key_pressed (R) - 1 word unsigned int, contains current
#                        debounced key.
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
# Registers changed: r8, r9, r2.
# Stack depth:       2 words.
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
                           # r2 = 0 (FALSE) if is illegal key, 1 (TRUE) if not

ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8         # adjust stack pointer

ret

# GetKey
#
#
# Description:       Returns the keycode (defined in interfac.h) for the debounced
#                    key, and does not return until there is a valid key.
#
# Operation:         Waits until there is a valid key from key_pressed, and
#                    returns the key value. Never returns KEY_ILLEGAL.
#
# Arguments:         None.
# Return Values:     key - int, the keycode for the debounced key.
#                       Always a valid key, never KEY_ILLEGAL.
#
# Local Variables:   None.
# Shared Variables:  key_pressed (R/W) - 1 word unsigned int, contains current
#                        debounced key.
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
# Registers changed: r2, r9, r10.
# Stack depth:       2 words.
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
ldw r2, 0(r9)               # load value in key_pressed
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

ret                    # have key, return

# keypadInterruptHandler
#
#
# Description:       Event handler for the keypad. Stores the current
#                    valid key value in key_pressed.
#
# Operation:         Reads in the keycode value and saves it in key_pressed if
#                    it is valid. Clears edge capture register and re-enables
#                    interrupts.
#
# Arguments:         None.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  key_pressed (W) - 1 word unsigned int, contains current
#                        debounced key.
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
# Registers changed: r8, r9, r10.
# Stack depth:       2 words.
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
movia r9, ROT_ADDRESS       # read in rotary pio core address
ldbio r10, 12(r9)

cmpeqi r8, r10, KEY_ILLEGAL 		  # check if current key value is illegal
bne r0, r8, endKeypadInterruptHandler # if current key is illegal key, end
                                      #     (all rotary actions are valid)

movia r8, key_pressed  # get address of key_pressed
stw r10, 0(r8)         # store pio data value from edge register in key_pressed

movui r8, 0
stbio r8, 12(r9)   # edge capture register, clear all

movi r8, 0x1f
stbio r8, 8(r9)    # interrupt mask register, enable interrupts

endKeypadInterruptHandler:
ldw r28, 0(sp)     # load return address
ldw ra, 4(sp)      # load frame pointer
addi sp, sp, 8     # adjust stack pointer

ret

# InitKeypad
#
#
# Description: Initializes keypad interrupts and variables. Registers keypad
#              event handler, initializes key_pressed with
#              KEY_ILLEGAL, initializes rotary PIO and enables interrupts.
#              Must be called before using the keypad.
#
# Operation: Registers keypad event handler, initializes key_pressed with
#            KEY_ILLEGAL, initializes rotary PIO and enables interrupts.
#
# Arguments:         None.
# Return Values:     None.
#
# Local Variables:   None.
# Shared Variables:  key_pressed (W) - 1 word unsigned int, contains current
#                        debounced key.
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
# Registers changed: r4, r5, r6, r8, r9.
# Stack depth:       2 words.
#
# Revision History: 06/06/17   Sophia Liu      initial revision
.align 4
.global initKeypad
.type initKeypad, @function
initKeypad:
addi sp, sp, -8        # adjust stack pointer
stw ra, 0(sp)          # store return address
stw r28, 4(sp)         # store frame pointer

movia r8, ROT_ADDRESS  # get rotary pio core address
movi r9, 0
stbio r9, 8(r8)        # interrupt mask register, disable interrupts

movui r4, 0            # arguments for alt_irq_register
movui r5, 0
movia r6, keypadInterruptHandler
call alt_irq_register  # register interrrupt handler for keypad (rotary) event

movia r8, key_pressed  # get key_pressed address
movi r9, KEY_ILLEGAL
stw r9, 0(r8)          # initialize key_pressed with illegal key

initInterrupts:
movia r8, ROT_ADDRESS  # get rotary pio core address
movi r9, 0x0
stbio r9, 4(r8)        # direction register for pio, set to input

movi r9, 0x0
stbio r9, 12(r8)       # edge capture register for pio, clear all

movi r9, 0x1f
stbio r9, 8(r8)        # interrupt mask register for pio, enable interrupts

ldw ra, 0(sp)          # load return address
ldw r28, 4(sp)         # load frame pointer
addi sp, sp, 8         # adjust stack pointer
ret

# data section
.section .data
.align 4
key_pressed: .word 0x0    # 1 word unsigned int, contains current debounced key
