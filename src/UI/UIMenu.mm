//
//  UIMenu.cpp
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/12/2014.
//
//

#include "UIMenu.h"
#include "ofApp.h"

//--------------------------------------------------------------
UIMenu::UIMenu(int width) : ofxUICanvas(width,100)
{
	setWidgetSpacing(1);

	mp_btnMood01 = new UIImageButton("btn01", 0,0,width/4,100,"GUI/mood_icons/glagla.png");
	mp_btnMood01->setDrawFill(true);
    mp_btnMood01->setDrawFillHighLight(false);
    mp_btnMood01->setDrawOutlineHighLight(false);

	mp_btnMood02 = new UIImageButton("btn02", 0,0,width/4,100, "GUI/mood_icons/grr.png");
	mp_btnMood02->setDrawFill(true);
    mp_btnMood02->setDrawFillHighLight(false);
    mp_btnMood02->setDrawOutlineHighLight(false);

	mp_btnMood03 = new UIImageButton("btn03", 0,0,width/4,100, "GUI/mood_icons/grr_2.png");
	mp_btnMood03->setDrawFill(true);
    mp_btnMood03->setDrawFillHighLight(false);
    mp_btnMood03->setDrawOutlineHighLight(false);

	mp_btnUserAccount = new UIImageButton("btn04", 0,0,width/4,100, "GUI/mood_icons/sad.png");
	mp_btnUserAccount->setDrawFill(true);
    mp_btnUserAccount->setDrawFillHighLight(false);
    mp_btnUserAccount->setDrawOutlineHighLight(false);

	addWidgetRight	(mp_btnMood01);
	addWidgetRight	(mp_btnMood02);
	addWidgetRight	(mp_btnMood03);
	addWidgetRight	(mp_btnUserAccount);

	autoSizeToFitWidgets();
	setAutoDraw(false);
	setColorBack( ofColor(0,0,0,100) );

    ofAddListener(newGUIEvent,this,&UIMenu::guiEvent);
}

//--------------------------------------------------------------
void UIMenu::guiEvent(ofxUIEventArgs &e)
{
	UIImageButton* pButton = (UIImageButton*) e.getButton();
	if (pButton == mp_btnUserAccount && pButton->getValue())
	{
		((ofApp*)ofGetAppPtr())->setViewProfile();
	}
}


