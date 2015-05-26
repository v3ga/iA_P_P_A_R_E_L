#pragma once

#include "ofxiOS.h"
#include "ofxiOSExtras.h"

#include "ofxQCAR.h"
#include "ofxXmlSettings.h"

#include "user.h"
#include "apparelModel.h"
#include "apparelModManager.h"

#include "oscReceiver.h"
#include "soundInput.h"
#include "ofxPostProcess.h"

#include "UI/UIManager.h"

class UIPageMain;
class ofApp : public ofxQCAR_App {
	
    public:
        void setup();
		void qcarInitialised();
        void update();
        void draw();
		void drawModel();
		void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);

		// SETTINGS
		ofxXmlSettings		m_settings;

		bool				m_bARMode;
		void				setARMode(bool is=true);


		// USER
		user				m_user;
		user*				mp_userCurrent;
 
		// USER TEMPLATES
		user				m_userTemplate[3];
 
 		// GUI
		// TODO : not really useful, to be removed
		UIPageMain*			mp_pageMain;
		UIManager			m_uiManager;

		// MODS
		apparelModel		m_apparelModel;
		apparelModManager	m_apparelModManager;
 
		apparelMod*			mp_modPorcu;

		// OSC
		oscReceiver			m_oscReceiver;

		// SOUND
	 	void 				audioIn			(float * input, int bufferSize, int nChannels);
		SoundInput			m_soundInput;
	
		// Touch point
	    ofPoint 			m_touchPoint;

		// UI events from view controllers
		void				onMoodSelected		(int moodIndex);
		void				onMoodUnselect		();
		void				onTemplateSelected	(int templateIndex);
 
		// Filter
		//ofxPostProcess*		mp_postProcess;
 		ofShader				m_shaderDither;
};


