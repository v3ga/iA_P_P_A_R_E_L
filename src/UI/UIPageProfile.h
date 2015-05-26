//
//  UIPageProfile.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/12/2014.
//
//

#pragma once
#include "UIPage.h"

class UIPageProfile : public UIPage
{
	public:
		UIPageProfile		(string id, UIManager* pManager);


		void				createControls	();
		void				draw			();

		ofxUICanvas*		mp_canvas;
		ofxUILabel*			mp_label;
 
};

