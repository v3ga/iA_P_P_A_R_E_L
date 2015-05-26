//
//  UIPageProfile.cpp
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/12/2014.
//
//

#include "UIPageProfile.h"


UIPageProfile::UIPageProfile(string id, UIManager* pManager) : UIPage(id, pManager)
{
	mp_canvas	= 0;
	mp_label 	= 0;
}

void UIPageProfile::createControls()
{
	mp_canvas = new ofxUICanvas( ofGetWidth(),ofGetHeight() );
	mp_label = mp_canvas->addLabel("Hello User");
//	mp_label->set
}

void UIPageProfile::draw()
{

}
