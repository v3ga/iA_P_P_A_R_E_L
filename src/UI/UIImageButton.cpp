//
//  UIImageButton.cpp
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/12/2014.
//
//

#include "UIImageButton.h"

//--------------------------------------------------------------
UIImageButton::UIImageButton(string name, float x, float y, float w, float h, string path) : ofxUIImageButton(x,y,w,h,false,path,name)
{
}

//--------------------------------------------------------------
void UIImageButton::drawFill()
{
	float s = 2.0f;

    if(/*draw_fill && */img)
    {
        ofxUINoFill();
        ofxUISetColor(ofColor(255,255));
		ofRect(rect->getX(),rect->getY(),rect->getWidth(),rect->getHeight());

        ofxUIFill();
        ofxUISetColor(color_fill);
        // img->draw(rect->getX(), rect->getY(), rect->getWidth(), rect->getHeight());
		float x = rect->getX()+(rect->getWidth()-s*img->getWidth())/2;
		float y = rect->getY()+(rect->getHeight()-s*img->getHeight())/2;

        img->draw(x,y,s*img->getWidth(),s*img->getHeight());

	}
}