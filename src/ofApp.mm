#include "ofApp.h"
#include "ofAppLog.h"
#include "globals.h"
#include "apparelMod_include.h"
#include "UI/UIPageMain.h"
#include "userTwitterGuestIOS.h"
#import <TwitterKit/TwitterKit.h>


//--------------------------------------------------------------
#define USE_VUFORIA				true
#define LOG_DEBUG				false

//--------------------------------------------------------------
static const string kLicenseKey = "AYJLA4X/////AAAAAQ7qnxRQs0iPmiGsXnjUeoVBg6LZewn8RdmNIDATnu/qc3Y9MYazpU6Gig1at3yF98S5Od5Wu4VZLiwhfvIv4PDYSfNCfphxQOwGTf7ifee69o2xBhwmGn5yNXddYoQjqdrEhNpj3M7WlBjMujiU2KDk4yucMr4hfc0+wsivYM9Vva90oJ5IK1wBzWa7P2s/t8Ags4Wzjlae8asQVb6406J0OkHwiNhneVdLTBNRERGJ0JLWbQMfHpnSRHGZaN33dqs1pLsxNSHMPAPhEqUzCav55eo5GGf/iZdO+EcK6qjnO2ySSkz7Cw26vezTSx5fLMa2ZlaNJsK92IBP00heA/Hlf27pDPA5KONuMmrEjV+Y";

//--------------------------------------------------------------
void ofApp::setup()
{
	mp_pageMain 				= 0;
	mp_modPorcu					= 0;
	mp_userCurrent				= 0;
	m_templateIndexSelected 	= -1;

	ofSetLogLevel(OF_LOG_VERBOSE);
	OFAPPLOG->begin("ofApp::setup()");
	
	ofSetLogLevel(OF_LOG_NOTICE);

	
	// DEBUG STUFF
	#if LOG_DEBUG
		OFAPPLOG->println("- OF renderer="+ofGetCurrentRenderer()->getType());
		OFAPPLOG->println("- GLSL version="+ofToString(glGetString(GL_SHADING_LANGUAGE_VERSION)));
		OFAPPLOG->println("- GL version="+ofToString(glGetString(GL_VERSION)));
		OFAPPLOG->println("- size = "+ofToString(ofGetWidth())+","+ofToString(ofGetHeight()));
	#endif

	// GLOBAL STUFF
	ofBackground(0);
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
	GLOBALS->setApp(this);
	
	// SETTINGS
	OFAPPLOG->println("- loading configuration.xml");

    if (m_settings.loadFile("configuration.xml"))
	{
		string modelObjName = m_settings.getValue("apparel:model", "");
		string targetName 	= m_settings.getValue("apparel:vuforia:target", "");
		string userId		= m_settings.getValue("apparel:user", "creativeclaude"); // DEPRECATED
		
		// FONTS
/*
		for (NSString* family in [UIFont familyNames])
		{
   			 NSLog(@"%@", family);
        
		    for (NSString* name in [UIFont fontNamesForFamilyName: family])
    		{
        		NSLog(@"  %@", name);
    		}
		}
*/

		// SCENE
		GLOBALS->setModel(&m_apparelModel);
		OFAPPLOG->println("- loading "+ modelObjName);
		if (m_apparelModel.load(modelObjName))
		{
			OFAPPLOG->println("- loaded 3d/" + modelObjName);
		}

		// MODS
		m_apparelModManager.constructMods(&m_apparelModel);
		GLOBALS->setModManager(&m_apparelModManager);

		mp_modPorcu = m_apparelModManager.getMod("Porcupinopathy");
		
		// SOUND
		m_soundInput.setup(0, 1);

		// NETWORK
		int oscPort = 1235;
		m_oscReceiver.setup(oscPort);
		m_oscReceiver.setModManager(&m_apparelModManager);
		OFAPPLOG->println("- osc receiver port = " + ofToString(oscPort));

	
		// GUI
		mp_pageMain = new UIPageMain("PageMain",&m_uiManager);
		mp_pageMain->setApparelModManager(&m_apparelModManager);
		mp_pageMain->setup();


		// USER
		if (Twitter.sharedInstance.session != nil)
		{
			changeUser( Twitter.sharedInstance.session.userID.UTF8String );
			userTwitterGuestIOS* pTwitterIOS = (userTwitterGuestIOS*) m_user.getService("twitter");
			if (pTwitterIOS)
				pTwitterIOS->retrieveInfo();
			
		}
		else
		{
			setARMode(false);
//			changeUser( getTemplateUserId(0) );
			changeUser( "test" ); // TEMP 

		}
		// VUFORIA
#if USE_VUFORIA
		OFAPPLOG->println("- loading vuforia targets " + targetName);
		ofxQCAR * qcar = ofxQCAR::getInstance();
	    qcar->setLicenseKey(kLicenseKey); // ADD YOUR APPLICATION LICENSE KEY HERE.
		qcar->addMarkerDataPath(targetName);
		qcar->autoFocusOn();
		qcar->setCameraPixelsFlag(true);
		qcar->setup();
#endif


	}

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void ofApp::qcarInitialised()
{

}

//--------------------------------------------------------------
void ofApp::setARMode(bool is)
{
	m_bARMode = is;
	if (mp_pageMain)
		mp_pageMain->setUseVuforia(is);
}

//--------------------------------------------------------------
void ofApp::update()
{
	float dt = ofGetLastFrameTime();

	m_oscReceiver.update();
	if (mp_userCurrent)
		mp_userCurrent->update(dt);
	if (mp_pageMain)
		mp_pageMain->update(dt);
 }

//--------------------------------------------------------------
void ofApp::draw()
{
	ofClear(0, 0, 0, 255);
	if (mp_pageMain)
		mp_pageMain->draw();
}

//--------------------------------------------------------------
void ofApp::exit()
{
	OFAPPLOG->begin("ofApp::exit()");
	
	if (mp_userCurrent)
		mp_userCurrent->saveServicesData();
	m_apparelModManager.saveParameters();
 
	ofxQCAR * qcar = ofxQCAR::getInstance();
	if (qcar)
		qcar->exit();

	m_soundInput.stop();
	
	OFAPPLOG->end();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch)
{
    m_touchPoint.set(touch.x, touch.y);
/*     ofxQCAR * qcar = ofxQCAR::getInstance();
	 if (qcar)
		qcar->startExtendedTracking();
*/
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch)
{
    m_touchPoint.set(touch.x, touch.y);
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    m_touchPoint.set(-1, -1);
/*
     ofxQCAR * qcar = ofxQCAR::getInstance();
	 if (qcar)
	     qcar->stopExtendedTracking();
*/

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch)
{
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}


//--------------------------------------------------------------
void ofApp::audioIn(float * input, int bufferSize, int nChannels)
{
	m_soundInput.audioIn(input,bufferSize,nChannels);
}

//--------------------------------------------------------------
void ofApp::changeUser(string userId, bool bTemplate)
{
	OFAPPLOG->begin("ofApp::changeUser('" + userId + "')");

	m_user.deconnect();

	m_user.setId(userId);
	m_user.setTemplate(bTemplate);
	m_user.setModManager(&m_apparelModManager);
	m_user.createDirectory();
	if (bTemplate == false)
		m_user.loadConfiguration(); // create social interfaces (twitter) instance here, factory call setup on social interfaces
	m_user.useTick(bTemplate ? false : true);
	m_user.connect();

	m_apparelModManager.countUserWords(&m_user);

	mp_userCurrent = &m_user;
	GLOBALS->setUser(mp_userCurrent);

	OFAPPLOG->end();
}


//--------------------------------------------------------------
void ofApp::onMoodSelected(int moodIndex)
{
	OFAPPLOG->begin("ofApp::onMoodSelected("+ofToString(moodIndex)+")");

	if (moodIndex == 0)		m_apparelModManager.selectMood("Sad");
	if (moodIndex == 1)		m_apparelModManager.selectMood("Noisopathy");
	if (moodIndex == 2)		m_apparelModManager.selectMood("Porcupinopathy");

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void ofApp::onMoodUnselect()
{
	OFAPPLOG->begin("ofApp::onMoodUnselect()");
	m_apparelModManager.unselectMood();
	OFAPPLOG->end();
}

//--------------------------------------------------------------
void ofApp::onTemplateSelected(int templateIndex)
{
//	if (templateIndex<3)
	{
//		changeUser( getTemplateUserId(templateIndex), true  ) ; // id, isTemplate
		m_templateIndexSelected = templateIndex;
	}
}






