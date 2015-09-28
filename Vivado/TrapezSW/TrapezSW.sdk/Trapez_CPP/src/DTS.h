/*
 * DTS.h
 *
 *  Created on: 28/09/2015
 *      Author: Alexander
 */

#ifndef DTS_H_
#define DTS_H_

class DTS_energy {
private:
	const static short b10 = -32754.2648225;//(short)(-0.999580835647357 * pow(2,15));
	const static short na = 100;
	const static short nb = 400;
	const static short FILE_SIZE = 32768/2; //12164; Half size of BRAM
	short x, x_1;
	int   xa[FILE_SIZE];
	int   xb[FILE_SIZE];
	int   xc, xc_1;
	short y, y_1;
	short threshold;
	short hyst_value;
	short state;
	int energySum;
	int counter;
	int n;

	// Recursive averaging filter
	const static short M = 100; // Average on old samples
	short xm_M[M]; // Old samples
	float ym_1; // Average, baseline
	int m; // Index pointer
	int avgCnt;
	int header; // Size of pulse header

	inline short zerocheck(short value) {
		if (value > 0)
			return value;
		else
			return 0;
	}

public:
	// Initialization of the variable
	DTS_energy() {
		memset(xa, 0, FILE_SIZE*sizeof(int));
		memset(xb, 0, FILE_SIZE*sizeof(int));
		threshold = 20;
		reset();
		header = 200;
	}

	void reset(void) {

		// Reset Trapez filter
		state = 0;
		energySum = 0;
		x_1 = 0;
		xb[0] = 0;
		xa[0] = 0;
		xc_1 = 0;
		y_1 = 0;
		n = 1;

		// Reset average filter
		avgCnt = 0;
		m = 0;
		ym_1 = 0.0;
		memset(xm_M, 0, M*sizeof(short));
	}

	void setPulseHeader(int size)
	{
        header = size;
	}

	short getBaseline(void)
	{
		return ym_1;
	}

	short average(short x)
	{
		float y = -1;

		// Compute baseline for head of pulse before threshold
		if (avgCnt < header) {

			// Recursive averaging filter
			// y(m) = 1/M (x(m) - x(m-M)) + y(m-1)
			y = (x - xm_M[m])/M + ym_1;
	        ym_1 = y;

			xm_M[m++] = x; // New sample in oldest position
			if (m >= M) m = 0; // Pointer wrap around

			avgCnt++;
		}

		return (short)y;
	}

	short filter(short sample) //, short &energy
	{
		// filter coefficients and the delays used by the trapez filter
		int res;
		short difference;

		// The Trapez filter divided into a 4 step cascade filter
		x = sample;
		res = b10 * x_1;
		xa[n] = x + (res >> 15);
		xb[n] = xa[n] - xa[zerocheck(n - na)] + xb[n - 1];
		xc = xb[n] - xb[zerocheck(n - nb)] + xc_1;
		y = xc_1 / na;

		difference = y - y_1;

		// Save values for next time
		y_1 = y;
		xc_1 = xc;
		x_1 = x;

		// Finding flat area of trapez peak top
		if (difference > threshold || difference < -threshold) {
			hyst_value = 1;
		}
		else {
			hyst_value = 0;
		}

		// Computes energy by averaging trapez peak top
		short energy = -1;
		switch (state)  {
		case 0:
			if (hyst_value == 1)
				state = 1;
			break;
		case 1:
			if (hyst_value == 0) {
				counter = 1;
				energySum = y;
				state = 2;
			}
			break;
		case 2:
			if (hyst_value == 1) {
				energy = energySum / counter;
				state = 3;
			}
			else {
				energySum += y;
				counter++;
			}
			if (counter > 1000)
				state = 0;
			break;
		case 3:
			// Search for first top only!!!
			//if (hyst_value == 0)
			//	state = 0;
			break;
		}
		// new pointer index used for xa and xb
		n++;

		return energy; // Trapezoidal filter output
	}
};


#endif /* DTS_H_ */