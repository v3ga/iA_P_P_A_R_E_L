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

#import <UIKit/UIKit.h>

class UIPageMain;
class ofApp : public ofxQCAR_App {
	
    public:
        void setup();
		void qcarInitARDone(NSError * error);

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


		// APP state
		ofxXmlSettings 		m_appState;
		bool				m_bLaunchFirstTime;
		bool				m_bARMode;

		void				setARMode			(bool is=true);
		bool				getARMode			(){return m_bARMode;}

		void				setLaunchFirstTime	(bool is=true);

		void				copyAppStateFileToDocuments	();
		void				beginTimerForInfoAlert		();
		void				cancelTimerForInfoAlert		();
		void				increaseNbLaunches			();
 
		bool				m_bWillShowInfoAlert;
		float				m_timeShowAlert;
		int					m_nbLaunches;

 
		// USER
		user				m_user;
		user*				mp_userCurrent;
 		bool				m_doInitUser;
		void				setupUser		();
		void				changeUser		(string userId, bool bTemplate=false);
 
 
		// USER TEMPLATES
		user				m_userTemplate[3];
		int					m_templateIndexSelected;

		void				setupTemplates				();
		int					getTemplateIndexSelected	(){return m_templateIndexSelected;}
 
 		// QCAR
		bool				m_bQCARInitDone;
 
 		// GUI
		// TODO : not really useful, to be removed
		UIPageMain*			mp_pageMain;
		UIManager			m_uiManager;
 

		void				setViewController			(UIView* p){mp_viewInfo = p;}
		UIView*				mp_viewInfo;

 
 
		void				saveAppState		();

		// MODS
		apparelModel		m_apparelModel;
		apparelModManager	m_apparelModManager;
 

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
		string				getTemplateUserId	(int templateIndex){return "template0"+ofToString(templateIndex+1);}
		user*				getUserTemplate		(string id);

		// UI events from alert view
 		void				onAlertInfoSwitch	();

 

		// Filter
		//ofxPostProcess*		mp_postProcess;
 		ofShader				m_shaderDither;
};


