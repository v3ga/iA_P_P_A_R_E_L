#include "ofApp.h"
#include "ofAppLog.h"
#include "globals.h"
#include "apparelMod_include.h"
#include "UI/UIPageMain.h"


//--------------------------------------------------------------
#define USE_VUFORIA				true
#define LOG_DEBUG				false

//--------------------------------------------------------------
static const string kLicenseKey = "AYJLA4X/////AAAAAQ7qnxRQs0iPmiGsXnjUeoVBg6LZewn8RdmNIDATnu/qc3Y9MYazpU6Gig1at3yF98S5Od5Wu4VZLiwhfvIv4PDYSfNCfphxQOwGTf7ifee69o2xBhwmGn5yNXddYoQjqdrEhNpj3M7WlBjMujiU2KDk4yucMr4hfc0+wsivYM9Vva90oJ5IK1wBzWa7P2s/t8Ags4Wzjlae8asQVb6406J0OkHwiNhneVdLTBNRERGJ0JLWbQMfHpnSRHGZaN33dqs1pLsxNSHMPAPhEqUzCav55eo5GGf/iZdO+EcK6qjnO2ySSkz7Cw26vezTSx5fLMa2ZlaNJsK92IBP00heA/Hlf27pDPA5KONuMmrEjV+Y";

//--------------------------------------------------------------
void ofApp::setup()
{
	mp_pageMain 		= 0;
	mp_modPorcu			= 0;

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
		string userId		= m_settings.getValue("apparel:user", "creativeclaude");

		// USER
		OFAPPLOG->println("- user is @" + userId);

 		m_user.setId(userId);
		m_user.setModManager(&m_apparelModManager);
		m_user.createDirectory();
		m_user.loadConfiguration();

		mp_userCurrent = &m_user;
		GLOBALS->setUser(mp_userCurrent);

		// USER TEMPLATES
		for (int i=0;i<3;i++)
		{
			m_userTemplate[i].setId("template0"+ofToString(i));
			m_userTemplate[i].setModManager(&m_apparelModManager);
			m_userTemplate[i].createDirectory();
			m_userTemplate[i].useTick(false);
			m_userTemplate[i].loadConfiguration();
		}

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

		// USER WORDS
		// this will initialize words count for each mod for this user
		m_apparelModManager.countUserWords(mp_userCurrent);

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
	
		// GUI
		mp_pageMain = new UIPageMain("PageMain",&m_uiManager);
		mp_pageMain->setApparelModManager(&m_apparelModManager);
		mp_pageMain->setup();

		setARMode(true);
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
	mp_pageMain->setUseVuforia(is);
}

//--------------------------------------------------------------
void ofApp::update()
{
	m_oscReceiver.update();
	if (mp_userCurrent)
		mp_userCurrent->update(0.0f);
 	if (mp_pageMain)
		mp_pageMain->update(0.0f);
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
void ofApp::onMoodSelected(int moodIndex)
{
	ofLog() << "moodIndex=" << moodIndex;
}

//--------------------------------------------------------------
void ofApp::onMoodUnselect()
{
}


//--------------------------------------------------------------
void ofApp::onTemplateSelected(int templateIndex)
{
	if (templateIndex<3)
	{
		mp_userCurrent = &m_userTemplate[templateIndex];
		GLOBALS->setUser(mp_userCurrent);
		
//		m_apparelModManager.constructMods(&m_apparelModel);
		m_apparelModManager.countUserWords(mp_userCurrent);
	}
}






