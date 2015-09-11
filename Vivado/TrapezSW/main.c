/*
 * Copyright (c) 2009-2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xgpio.h"
#include "XScuTimer.h"
#include "led_ip.h"
#include "stdio.h"
#include "matrix_ip.h"

//====================================================
#define ONE_SECOND 333000000 // half of the CPU clock speed

// Matrix size
#define MSIZE 4

short input[100] =
{
#include "Test.txt"
}

typedef union {
  unsigned char comp[MSIZE];
  unsigned int vect;
  } vectorType;

typedef vectorType VectorArray[MSIZE];

void setInputMatrices(VectorArray A,VectorArray B);
void displayMatrix(VectorArray input);
void multiMatrixSoft(VectorArray A,VectorArray B, VectorArray P);
void multiMatrixHard(VectorArray A,VectorArray B, VectorArray P);

void setInputMatrices(VectorArray A,VectorArray B)
{
	A[0].vect = 0x04030201;
	B[0].vect = 0x01010101;
	A[1].vect = 0x08070605;
	B[1].vect = 0x02020202;
	A[2].vect = 0x0C0B0A09;
	B[2].vect = 0x03030303;
	A[3].vect = 0x100F0E0D;
	B[3].vect = 0x04040404;
}

void displayMatrix(VectorArray input)
{
	printf("Matrix :\n");
	printf("%2d %2d %2d %2d\n", input[0].comp[0],
			                	input[0].comp[1],
			                	input[0].comp[2],
			                	input[0].comp[3]);
	printf("%2d %2d %2d %2d\n", input[1].comp[0],
			                	input[1].comp[1],
			                	input[1].comp[2],
			                	input[1].comp[3]);
	printf("%2d %2d %2d %2d\n", input[2].comp[0],
			                	input[2].comp[1],
			                	input[2].comp[2],
			                	input[2].comp[3]);
	printf("%2d %2d %2d %2d\n", input[3].comp[0],
			                	input[3].comp[1],
			                	input[3].comp[2],
			                	input[3].comp[3]);

}

void multiMatrixSoft(VectorArray A,VectorArray B, VectorArray P)
{
	int row, col, k;
	for (row = 0; row < MSIZE; row++)
	{
		for (col = 0; col < MSIZE; col++)
		{
			P[row].comp[col] = 0;
			for (k = 0; k < MSIZE; k++)
				P[row].comp[col] += A[row].comp[k] * B[col].comp[k];
		}
	}

}

void multiMatrixHard(VectorArray A,VectorArray B, VectorArray P)
{
	int row, col;
	for (row = 0; row < MSIZE; row++)
	{
		for (col = 0; col < MSIZE; col++)
		{
			//P[row].comp[col] = 0;
			//for (k = 0; k < MSIZE; k++)
			//	P[row].comp[col] += A[row].comp[k] * B[col].comp[k];
			Xil_Out32(XPAR_MATRIX_IP_0_S00_AXI_BASEADDR + MATRIX_IP_S00_AXI_SLV_REG0_OFFSET, A[row].vect);
			Xil_Out32(XPAR_MATRIX_IP_0_S00_AXI_BASEADDR + MATRIX_IP_S00_AXI_SLV_REG1_OFFSET,  B[col].vect);
			P[row].comp[col] = Xil_In32(XPAR_MATRIX_IP_0_S00_AXI_BASEADDR + MATRIX_IP_S00_AXI_SLV_REG2_OFFSET);
		}
	}

}

//====================================================

int main (void)
{
      XGpio sw, push; // led;
	  int i, pshb_check, sw_check, Status, count, CntValue;

	  XScuTimer Timer;		/* Cortex A9 SCU Private Timer Instance */
      // PS Timer related definitions
      XScuTimer_Config *ConfigPtr;
      XScuTimer *TimerInstancePtr = &Timer;

 	  VectorArray AInst;
	  VectorArray BTinst;
	  VectorArray PInst;
	  int running = 1;

	  init_platform();

	  printf("-- Start of the Program --\r\n");

	  XGpio_Initialize(&sw, XPAR_SWITCHES_DEVICE_ID);
	  XGpio_SetDataDirection(&sw, 1, 0xffffffff);

	  XGpio_Initialize(&push, XPAR_BUTTONS_DEVICE_ID);
	  XGpio_SetDataDirection(&push, 1, 0xffffffff);

	  // Initialize the timer
	  ConfigPtr = XScuTimer_LookupConfig (XPAR_PS7_SCUTIMER_0_DEVICE_ID);
	  Status = XScuTimer_CfgInitialize	(TimerInstancePtr, ConfigPtr, ConfigPtr->BaseAddr);
	  if(Status != XST_SUCCESS){
		  printf("Timer init() failed\r\n");
		  return XST_FAILURE;
	  }

	  // Load timer with delay in multiple of ONE_SECOND
	  XScuTimer_LoadTimer(TimerInstancePtr, ONE_SECOND);
	  // Set AutoLoad mode
	  XScuTimer_EnableAutoReload(TimerInstancePtr);

	  printf("Enter choice: 1 (SW->Leds), 2 (Timer->Leds), 3 (Push buttons)\r\n");
	  printf("              4 (Matrix-SW), 5 (Matrix-HW), 6 (Exit)\r\n");

	  while (running)
	  {
		  char value, skip;

		  xil_printf("CMD:> ");
	      /* Read an input value from the console. */
	      value = inbyte();
	      skip = inbyte(); //CR
	      skip = inbyte(); //LF

	      switch (value)
	      {
	      	  case '1':
	      		  printf("-- Set switches to see LEDs lit --\r\n");
	      		  printf("-- Change slide switches to see corresponding output on LEDs --\r\n");
	      		  printf("-- Push BTN0 button to exit the program --\r\n");
	      		  while (1) {
					  sw_check = XGpio_DiscreteRead(&sw, 1);
					  // output dip switches value on LED_ip device
					  LED_IP_mWriteReg(XPAR_LED_IP_0_S_AXI_BASEADDR, 0, sw_check);
					  pshb_check = XGpio_DiscreteRead(&push, 1);
					  if(pshb_check & 0x01) {
			      		  printf("-- Switch test stopped --\r\n");
						  break;
					  }
	      		  }
	      		  break;

	      	  case '2':
	      		   // Start the timer
	      		  XScuTimer_Start (TimerInstancePtr);
	      		  count = 0;
	      		  printf("-- Timer test --\r\n");
	      		  printf("-- Push BTN0 button to exit the program --\r\n");

	      		  while (1) {
					  if(XScuTimer_IsExpired(TimerInstancePtr)) {
						  // clear status bit
						  XScuTimer_ClearInterruptStatus(TimerInstancePtr);
						  // output the count to LED and increment the count
						  LED_IP_mWriteReg(XPAR_LED_IP_0_S_AXI_BASEADDR, 0, count);
						  count++;
						  CntValue = XScuTimer_GetCounterValue(TimerInstancePtr);
						  printf("timer %d\r\n", CntValue);
					  }
					  pshb_check = XGpio_DiscreteRead(&push, 1);
					  if(pshb_check & 0x01)
					  {
						  XScuTimer_Stop(TimerInstancePtr);
			      		  printf("-- Timer test stopped --\r\n");
						  break;
					  }
	      		  }
	      		  break;

	      	  case '3':
	      		  printf("-- Push buttons to see LEDs lit --\r\n");
	      		  printf("-- Push BTN0 button to exit the program --\r\n");

	      		  while (1) {
	      			  pshb_check = XGpio_DiscreteRead(&push, 1);
	      			  //printf("Pushed: 0x%08x\r\n", pshb_check);
					  LED_IP_mWriteReg(XPAR_LED_IP_0_S_AXI_BASEADDR, 0, pshb_check);
					  if (pshb_check & 0x01) {
			      		  printf("-- Push buttons test stopped --\r\n");
						  break;
					  }
	      		  }
	      		  break;

	      	  case '4':
	  			  setInputMatrices(AInst, BTinst);
	  			  displayMatrix(AInst);
	  			  displayMatrix(BTinst);
	      		  XScuTimer_Start (TimerInstancePtr);
				  CntValue = XScuTimer_GetCounterValue(TimerInstancePtr);
				  multiMatrixSoft(AInst, BTinst, PInst);
				  CntValue = CntValue - XScuTimer_GetCounterValue(TimerInstancePtr);
				  printf("SW timer %d\r\n", CntValue); // 1901 ticks
				  XScuTimer_Stop(TimerInstancePtr);
				  displayMatrix(PInst);
	      		  break;

	      	  case '5':
	  			  setInputMatrices(AInst, BTinst);
	  			  displayMatrix(AInst);
	  			  displayMatrix(BTinst);
	      		  XScuTimer_Start (TimerInstancePtr);
				  CntValue = XScuTimer_GetCounterValue(TimerInstancePtr);
				  multiMatrixHard(AInst, BTinst, PInst);
				  CntValue = CntValue - XScuTimer_GetCounterValue(TimerInstancePtr);
				  printf("HW timer %d\r\n", CntValue); // 3629 ticks
				  XScuTimer_Stop(TimerInstancePtr);
				  displayMatrix(PInst);
	      		  break;

	      	  case '6':
	      		  running = 0;
	      		  break;
	      	  default:
	      		  break;
	      }

		  for (i=0; i<9999999; i++); // delay loop
	  }

	  printf("-- End of Program --\r\n");
	  return 0;
}
