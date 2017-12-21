# ###########################################################################
#                                                                           #
#                    Reset functions for digital oscilloscope               #
#                                   EE 52                                   #
#                                                                           #
#                                                                           #
# ###########################################################################
# Name of file: reset.s
# Description: Reset functions for digital oscilloscope
# Public functions:
#    void pulse_wd(void): Pulses the watchdog reset output that is sent to the
#              reset chip. The reset input on the MAX705 used must be toggled
#              at least every 1.6 secs. If this function is not called within
#              that time, the system will reset.
# Local functions:
# Input:    None
# Output:   None
#
# Revision History:
#     06/24/17 Sophia Liu     initial revision
#     12/17    Sophia Liu     edited comments


# inc header files for constants
#include "general.h"

# pulse wd
#
#
# Description: Pulses the watchdog reset output that is sent to the reset
#              chip. The reset input on the MAX705 used must be toggled
#              at least every 1.6 secs. If this function is not called within
#              that time, the system will reset.
#
# Operation: Gets the reset PIO address and sets the output high then low.
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
# Stack depth:       0 words.
#
# Revision History: 06/24/17   Sophia Liu      initial revision
.section .text
.align 4
.global pulse_wd
.type pulse_wd, @function
pulse_wd:
movia r8, WD_PIO # get watchdog input pio address
movi r9, 1
stbio r9, 0(r8)  # set watchdog input high

movi r9, 0
stbio r9, 0(r8)  # set watchdog input low

ret
