/****************************************************************************/
/*                                                                          */
/*                                INTERFAC.H                                */
/*                           Interface Definitions                          */
/*                               Include File                               */
/*                       Digital Oscilloscope Project                       */
/*                                 EE/CS 52                                 */
/*                                                                          */
/****************************************************************************/

/*
   This file contains the constants for interfacing between the C code and
   the assembly code/hardware for the Digital Oscilloscope project.  This is
   a sample interface file to allow compilation of the .c files.


   Revision History:
      3/8/94   Glen George       Initial revision.
      3/13/94  Glen George       Updated comments.
      3/17/97  Glen George       Added constant MAX_SAMPLE_SIZE and removed
	                         KEY_UNUSED.
*/



#ifndef  __INTERFAC_H__
    #define  __INTERFAC_H__


/* library include files */
  /* none */

/* local include files */
  /* none */




/* constants */

/* keypad constants */
#define  KEY_MENU       0	/* <Menu>      */
#define  KEY_UP         1	/* <Up>        */
#define  KEY_DOWN       2	/* <Down>      */
#define  KEY_LEFT       3	/* <Left>      */
#define  KEY_RIGHT      4	/* <Right>     */
#define  KEY_ILLEGAL    6	/* illegal key */

/* display constants */
#define  SIZE_X         480	/* size in the x dimension */
#define  SIZE_Y		    272     /* size in the y dimension */
#define  PIXEL_WHITE      0     /* pixel off */
#define  PIXEL_BLACK      1     /* pixel on */

/* scope parameters */
#define  MIN_DELAY	   0    /* minimum trigger delay */
#define  MAX_DELAY     50000    /* maximum trigger delay */
#define  MIN_LEVEL         0    /* minimum trigger level (in mV) */
#define  MAX_LEVEL      5000    /* maximum trigger level (in mV) */

/* sampling parameters */
#define  MAX_SAMPLE_SIZE   2400 /* maximum size of a sample (in samples) */


#endif
