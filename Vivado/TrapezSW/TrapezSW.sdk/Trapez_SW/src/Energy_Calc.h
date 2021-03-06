
class Energy{
private:
	short state;
	int energySum;
	int counter;


public:
	Energy(void) {
		state = 0;
		energySum = 0;
	}

	short energyState(short hyst, short trapez)
	{
		short energy = -1;

		switch (state)  {
		case 0:
			if (hyst == 1)
				state = 1;
			break;
		case 1:
			if (hyst == 0) {
				counter = 1;
				energySum = trapez;
				state = 2;
			}
			break;
		case 2:
			if (hyst == 1) {
				energy = energySum / counter;
				state = 3;
			}
			else {
				energySum += trapez;
				counter++;
			}
			if (counter > 1000)
				state = 0;
			break;
		case 3:
			if (hyst == 0)
				state = 0;
			break;
		}

		return energy;
	}
};



