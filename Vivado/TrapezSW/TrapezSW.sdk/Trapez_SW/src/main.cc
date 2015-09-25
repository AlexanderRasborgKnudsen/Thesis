#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xgpio.h"
#include "XScuTimer.h"
//#include "led_ip.h"
#include "stdio.h"
//#include "matrix_ip.h"
#include "Diff.h"
#include "Hysterese.h"
#include "Trapez_filter.h"
#include "Energy_Calc.h"
#include "Tools.h"

using namespace std;

//====================================================
#define ONE_SECOND 333000000 // half of the CPU clock speed

// Matrix size
#define MSIZE 4

short input[10];

/*
short input[12164] =
{
#include "TPE_38_1_mod_3.txt"
};
*/



int main(void)
{
	  	XScuTimer Timer;		/* Cortex A9 SCU Private Timer Instance */
	  	// PS Timer related definitions
	    XScuTimer_Config *ConfigPtr;
    	XScuTimer *TimerInstancePtr = &Timer;
    	int CntValue, Status;
    	short a;

	    //init_platform();

  	    // Initialize the timer
  	    ConfigPtr = XScuTimer_LookupConfig (XPAR_PS7_SCUTIMER_0_DEVICE_ID);
  	    Status = XScuTimer_CfgInitialize(TimerInstancePtr, ConfigPtr, ConfigPtr->BaseAddr);
  	    if(Status != XST_SUCCESS){
  		    printf("Timer init() failed\r\n");
  		    return XST_FAILURE;
  	    }

  	    // Load timer with delay in multiple of ONE_SECOND
  	    XScuTimer_LoadTimer(TimerInstancePtr, ONE_SECOND);
  	    // Set AutoLoad mode
  	    XScuTimer_EnableAutoReload(TimerInstancePtr);

	  	printf("-- Start of the Program --\r\n");


		// Create instance of Trapez_filter
		Trapez_filter myFilter = Trapez_filter();
		Energy CalcEnergy = Energy();
		Diff Difference = Diff();
		Hysterese myHysterese = Hysterese();
		ZeroCheck myMax = ZeroCheck();

		// Load a datafile from the directory of the main file
		//std::ifstream infile("TPE_38_1_mod_3.txt");

		// Array for the output data
		const static short FILE_SIZE = 12164;
		short result[FILE_SIZE];
		short energyPeak = 0;
		short differentiate = 0;
		short hysterese = 0;
		short energyAvg = 0;
		input[0] = 0;

		// Initialization of the variable
		memset(result, 0, FILE_SIZE);



		for (int i = 0; i < (FILE_SIZE); i++) {
			XScuTimer_Start (TimerInstancePtr);
			// output of the filter i stored in the result array
			a = input[i];
			a = a - 1500;
	 		result[i] = myFilter.filter(a);
			differentiate = Difference.diff(result[i], result[myMax.zerocheck(i - 1)]);
			hysterese = myHysterese.hyst(differentiate);
			energyPeak = CalcEnergy.energyState(hysterese, result[i]);
			if (energyPeak != -1) {
				energyAvg = energyPeak;
			}
		}
		XScuTimer_Stop(TimerInstancePtr);
		CntValue = XScuTimer_GetCounterValue(TimerInstancePtr);
		printf("timer %d\r\n", CntValue);

		//ofstream myfile;
		//myfile.open("Result.csv");

		//myfile << energyAvg << endl;

		//for (int i = 0; i < (FILE_SIZE-1); i++) {
		//	myfile << result[i] << endl;
		//}

		//myfile.close();
		printf("%2d \n", energyAvg);
		printf("-- End of Program --\r\n");
		return 0;
}
