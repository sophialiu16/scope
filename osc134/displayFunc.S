# ###########################################################################
#                                                                           #
#                  Display functions for digital oscilloscope               #
#                                   EE 52                                   #
#                                                                           #
#                                                                           #
# ###########################################################################
# Name of file: display.s
# Description: Display functions for digital oscilloscope
# Public functions:
#     void clear_display(void): Clears the display (turns black) by storing
#         the pixel off value (PIXEL_WHITE) in all VRAM locations.
#     void plot_pixel(unsigned int x, unsigned int y, int p): Sets the pixel at
#         the passed position (x, y) to the passed value p. The position is
#         passed in binary with (0,0) being the upper left corner.
#
# Local functions: None.
#
# Input:    None.
# Output:   None.
#
# Revision History: 06/06/17 Sophia Liu     Initial revision
#                   09/04/17 Sophia Liu     Edited comments
#                   12/2017  Sophia Liu     Edited comments

# inc files for display constants
#include "interfac.h"
#include "general.h"

# Clear display
#
#
# Description: Clears the display (turns black) by storing the pixel off value
#              (PIXEL_WHITE) in all VRAM locations.
#
# Operation: Goes through each VRAM address and stores PIXEL_WHITE (pixel off)
#            at each location.
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
# Registers changed: r6, r9, r11, r12, r13
# Stack depth: 0 words.
#
# Revision History: 06/22/17   Sophia Liu      initial revision
.section .text
.align 4
.global clear_display
.type clear_display, @function
clear_display:
movia	r6, VRAM_ADDRESS      # store vram beginning address
movia	r13, VRAM_ADDRESS_END # store vram ending address
movi	r9, PIXEL_WHITE       # store value for pixel off
movi	r12, TRUE             # store value for true, for comparisons

clear_display_start:
stb		r9, 0(r6)             # clear next vram byte
addi	r6, r6, 1             # move to next address

cmpeq	r11, r6, r13                  # check if reached end of vram
beq		r11, r12, clear_display_end   # if reached end address, end function
jmpi	clear_display_start           # else move to next address

clear_display_end:
ret

# Plot_pixel
#
# Description: Sets the pixel at the passed position (x, y) to the passed
#              value p. The position is passed in binary with (0,0) being the
#              upper left corner.
#
# Operation: Checks to make sure the position (x, y) is with the bounds of the
#            display screen. If it is, the corresponding vram address is
#            calculated and the pixel value p is stored.
#
# Arguments:         unsigned int x (r4) - x value of pixel to plot, with (0,0)
#                        being the upper left corner.
#                    unsigned int y (r5)- y value of pixel to plot, with (0,0)
#                        being the upper left corner.
#                    int p (r6) - 8-bit value of the pixel to plot.
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
# Registers changed: r8, r9, r10, r11.
# Stack depth:       0 words.
#
# Revision History: 06/22/17   Sophia Liu      initial revision
.section .text
.align 4
.global plot_pixel
.type plot_pixel, @function
plot_pixel:
check_pixel:
movi r9, TRUE
cmpgei r8, r4, SIZE_X       # check if x point is too large for LCD
beq r8, r9, invalid_point   # if it is invalid, end

cmpgei r8, r5, SIZE_Y       # check if y point is too large for LCD
beq r8, r9, invalid_point   # if it is invalid, end

movia r10, VRAM_ADDRESS     # get vram address
add r10, r4, r10            # add x offset to vram address

muli r11, r5, VRAM_WIDTH    # multiply y by length of vram row for y offset
add r10, r11, r10           # add y offset to vram address

stb r6, 0(r10)              # store pixel byte value in vram address
jmpi end_plot

invalid_point:             # invalid point, return
ret

end_plot:                  # plotted point, return
ret
