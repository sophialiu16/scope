/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
extern void vram_test(void);
int main()
{
  printf("Hello from Nios II!\n");
  vram_test();
  char* VRAMAddr = 0x140000;
  char val = 0;
  int rowCount = 0;
  while (VRAMAddr < 0x180000)
  {
	  int i = 0;
	  for (i = 0; i < 512; i++)
	  {
		  unsigned int diff = ((unsigned int)VRAMAddr) % 32;

		  if (diff < 16)
		  {
			  *VRAMAddr = ~val;
		  }
		  else
		  {
			  *VRAMAddr = val;
		  }

		  VRAMAddr++;
	  }
	  rowCount++;
	  if(rowCount >= 16)
	  {
		  val = ~val;
		  rowCount = 0;
	  }
	  //*VRAMAddr = 0x00;
	  //VRAMAddr++;

  }
  return 0;
}
