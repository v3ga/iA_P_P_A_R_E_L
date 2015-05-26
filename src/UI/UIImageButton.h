//
//  UIImageButton.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/12/2014.
//
//

#pragma once
#include "ofxUIImageButton.h"

class UIImageButton : public ofxUIImageButton
{
	public:
		UIImageButton	(string name, float x, float y, float w, float h, string path);



		void			drawFill			();

    	void 			drawBack			(){}
    	void 			drawOutline			(){}
    	void 			drawOutlineHighlight(){}
    	void 			drawFillHighlight	(){}
    	void 			drawPadded			(){}
	    void 			drawPaddedOutline	(){}

};
