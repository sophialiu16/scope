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
#    void pulse_wd(void)
# Local functions:
# Input:    None
# Output:   None
#
# Revision History: 06/24/17 Sophia Liu     initial revision

# inc header files for constants
#include "general.h"

# pulse wd 
#
#
# Description: 
#
# Operation: 
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
.global pulse_wd
.type pulse_wd, @function 
pulse_wd:
movia r8, WD_PIO // get watchdog input pio address
movi r9, 1 
stbio r9, 0(r8)  // set watchdog input high 

movi r9, 0
stbio r9, 0(r8)  // set watchdog input low 

ret