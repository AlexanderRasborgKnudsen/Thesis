/*
 * DTS_energy.h
 *
 *  Created on: 22/09/2015
 *      Author: Alexander
 */

#ifndef DTS_ENERGY_H_
#define DTS_ENERGY_H_

#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <algorithm>
#include "Tools.h"


using namespace std;



class DTS_energy {
private:
	const static short FILE_SIZE = 12164;
	short x[FILE_SIZE];
	int xa[FILE_SIZE];
	int xb[FILE_SIZE];
	int xc[FILE_SIZE];
	short y[FILE_SIZE];
	short difference;
	short threshold;
	short hyst_value;
	short state;
	int energySum;
	int counter;
	int n;




public:
	// Initialization of the variable
	DTS_energy() {
		memset(x, 0, FILE_SIZE);
		memset(xa, 0, FILE_SIZE);
		memset(xb, 0, FILE_SIZE);
		memset(xc, 0, FILE_SIZE);
		memset(y, 0, FILE_SIZE);
		difference = 0;
		state = 0;
		energySum = 0;
		threshold = 20;
		n = 1;
	}


	short filter(short sample)
	{
		ZeroCheck myMax = ZeroCheck();
		// filter coefficients and the delays used by the trapez filter
		const short b10 = -32754.2648225;//(short)(-0.999580835647357 * pow(2,15));
		static short na = 100;
		static short nb = 400;
		int res;

		// The Trapez filter devidied into a 4 step carcade filter
		x[n] = sample;
		res = b10 * x[n - 1];
		xa[n] = x[n] + (res >> 15);
		xb[n] = xa[n] - xa[myMax.zerocheck(n - na)] + xb[n - 1];
		xc[n] = xb[n] - xb[myMax.zerocheck(n - nb)] + xc[n - 1];
		y[n] = (xc[n - 1]) / na;

		difference = y[n] - y[n - 1];

		if (difference > threshold || difference < -threshold) {
			hyst_value = 1;
		}
		else {
			hyst_value = 0;
		}

		short energy = -1;

		switch (state)  {
		case 0:
			if (hyst_value == 1)
				state = 1;
			break;
		case 1:
			if (hyst_value == 0) {
				counter = 1;
				energySum = y[n];
				state = 2;
			}
			break;
		case 2:
			if (hyst_value == 1) {
				energy = energySum / counter;
				state = 3;
			}
			else {
				energySum += y[n];
				counter++;
			}
			if (counter > 1000)
				state = 0;
			break;
		case 3:
			if (hyst_value == 0)
				state = 0;
			break;
		}
		n++;

		// new pointer index used on the output
		return energy;
	}
};



#endif /* DTS_ENERGY_H_ */
