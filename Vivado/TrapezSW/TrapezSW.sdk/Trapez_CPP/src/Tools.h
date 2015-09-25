/*
 * Tools.h
 *
 *  Created on: 17/09/2015
 *      Author: Alexander
 */

#ifndef TOOLS_H_
#define TOOLS_H_

class ZeroCheck {
private:
	short state;

public:
	ZeroCheck(void) { state = 0; }

short zerocheck(short value) {
	if (value > 0){
		return value;
	}
	else{
		return 0;
	}
	}
};



#endif /* TOOLS_H_ */
