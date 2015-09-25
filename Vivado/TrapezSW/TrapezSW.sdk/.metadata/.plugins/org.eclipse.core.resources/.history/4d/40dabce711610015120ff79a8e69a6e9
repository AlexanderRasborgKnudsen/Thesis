/*
 * Trapez_filter.h
 *
 *  Created on: 17/09/2015
 *      Author: Alexander
 */

#ifndef TRAPEZ_FILTER_H_
#define TRAPEZ_FILTER_H_

#include "Tools.h"

class Trapez_filter {
private:
	const static short FILE_SIZE = 12164;
	short x[FILE_SIZE]; // input vector
	int xa[FILE_SIZE]; // input vector
	int xb[FILE_SIZE]; // input vector
	int xc[FILE_SIZE]; // input vector
	short y[FILE_SIZE]; // output vector
	int n;    // pointer to the current array index




public:
	// Initialization of the variable
	Trapez_filter() {
		memset(x, 0, FILE_SIZE);
		memset(xa, 0, FILE_SIZE);
		memset(xb, 0, FILE_SIZE);
		memset(xc, 0, FILE_SIZE);
		memset(y, 0, FILE_SIZE);
		n = 1;
	}


	short filter(short sample)
	{
		// filter coefficients and the delays used by the trapez filter
		ZeroCheck myMax = ZeroCheck();
		const short b10 = -32754.2648225;
		static short na = 100;
		static short nb = 400;
		int res;

		// The Trapez filter devidied into a 4 step carcade filter
 		x[n] = sample;
		res = b10 * x[n - 1];
		xa[n] = x[n] + (res >> 15);
		xb[n] = xa[n] - xa[myMax.zerocheck(n - na)] + xb[n - 1];
		xc[n] = xb[n] - xb[myMax.zerocheck(n - nb) ] + xc[n - 1];
		y[n] = (xc[n - 1]) / na;

		// new pointer index used on the output
		return y[n++];
	}
};



#endif /* TRAPEZ_FILTER_H_ */
