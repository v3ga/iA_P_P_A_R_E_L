//
//  UIMenu.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/12/2014.
//
//

#pragma once
#include "ofMain.h"
#include "ofxUI.h"
#include "UIImageButton.h"

class UIMenu : public ofxUICanvas
{
	public:
		UIMenu		(int width);

	
		void		guiEvent(ofxUIEventArgs &e);


	private:
		UIImageButton*	mp_btnMood01;
		UIImageButton*	mp_btnMood02;
		UIImageButton*	mp_btnMood03;
		UIImageButton*	mp_btnUserAccount;

};
