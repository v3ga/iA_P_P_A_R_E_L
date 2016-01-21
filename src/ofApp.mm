#include "ofApparel.h"
#include "ofAppLog.h"
#include "globals.h"
#include "apparelMod_include.h"
#include "UI/UIPageMain.h"
#include "userTwitterGuestIOS.h"

#import <TwitterKit/TwitterKit.h>
#import "UI/AppAlert.h"


//--------------------------------------------------------------
#define USE_VUFORIA				true
#define LOG_DEBUG				false
#define USE_OSC					false

//--------------------------------------------------------------
static const string kLicenseKey = "AYJLA4X/////AAAAAQ7qnxRQs0iPmiGsXnjUeoVBg6LZewn8RdmNIDATnu/qc3Y9MYazpU6Gig1at3yF98S5Od5Wu4VZLiwhfvIv4PDYSfNCfphxQOwGTf7ifee69o2xBhwmGn5yNXddYoQjqdrEhNpj3M7WlBjMujiU2KDk4yucMr4hfc0+wsivYM9Vva90oJ5IK1wBzWa7P2s/t8Ags4Wzjlae8asQVb6406J0OkHwiNhneVdLTBNRERGJ0JLWbQMfHpnSRHGZaN33dqs1pLsxNSHMPAPhEqUzCav55eo5GGf/iZdO+EcK6qjnO2ySSkz7Cw26vezTSx5fLMa2ZlaNJsK92IBP00heA/Hlf27pDPA5KONuMmrEjV+Y";
static bool setupOnce = false;

//--------------------------------------------------------------
void ofApp::saveAppState()
{
	OFAPPLOG->begin("ofApp::saveAppState");

	m_appState.setValue("launchFirstTime", m_bLaunchFirstTime ? 1 : 0);
	m_appState.setValue("ar", m_bARMode ? 1 : 0);
	m_appState.setValue("nbLaunches", m_nbLaunches);

	OFAPPLOG->println("- m_bLaunchFirstTime="+ofToString(m_bLaunchFirstTime));
	OFAPPLOG->println("- m_bARMode="+ofToString(m_bARMode));
	OFAPPLOG->println("- m_nbLaunches="+ofToString(m_nbLaunches));

	m_appState.save(ofxiOSGetDocumentsDirectory()+"appstate.xml");

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void ofApp::copyAppStateFileToDocuments()
{
	OFAPPLOG->begin("ofApp::copyAppStateFileToDocuments");

	string pathFileResources = ofToDataPath("appstate.xml");
	string pathFileDocuments = ofxiOSGetDocumentsDirectory() + "appstate.xml";
	
	ofFile fDocuments(pathFileDocuments);
	if ( !fDocuments.exists() )
	{
		OFAPPLOG->begin(" - "+pathFileDocuments+" does not exist, copying from resources)");
		if (ofFile::copyFromTo(pathFileResources, pathFileDocuments, false, false))
		{
			OFAPPLOG->begin("- copied OK");
		}
	}
	
	OFAPPLOG->end();
}

//--------------------------------------------------------------
void ofApp::beginTimerForInfoAlert()
{
	m_bWillShowInfoAlert = true;
}

//--------------------------------------------------------------
void ofApp::cancelTimerForInfoAlert()
{
	m_bWillShowInfoAlert = false;
}

//--------------------------------------------------------------
void ofApp::setup()
{
	if (setupOnce == true) return;
	setupOnce = true;

	OFAPPLOG->begin("ofApp::setup()");

	mp_pageMain 				= 0;
	mp_viewInfo					= 0;

	mp_userCurrent				= 0;
	m_doInitUser				= true;
	m_templateIndexSelected 	= -1;
	
	m_bWillShowInfoAlert		= false;
	m_timeShowAlert				= 5.0f;
	m_nbLaunches				= 1;

	m_bQCARInitDone				= false;
	
	ofSetLogLevel(OF_LOG_NOTICE);

	// DEBUG STUFF
	#if LOG_DEBUG
		OFAPPLOG->println("- OF renderer="+ofGetCurrentRenderer()->getType());
		OFAPPLOG->println("- GLSL version="+ofToString(glGetString(GL_SHADING_LANGUAGE_VERSION)));
		OFAPPLOG->println("- GL version="+ofToString(glGetString(GL_VERSION)));
		OFAPPLOG->println("- size = "+ofToString(ofGetWidth())+","+ofToString(ofGetHeight()));
	#endif
	
	// APP State
	copyAppStateFileToDocuments();
	
	m_bLaunchFirstTime			= true;
	if (m_appState.load(ofxiOSGetDocumentsDirectory()+"appstate.xml"))
	{
		OFAPPLOG->println("- ok loaded appstate.xml (in documents)");

		
		m_bLaunchFirstTime 	= m_appState.getValue("launchFirstTime", 1) > 0;
		m_bARMode 			= m_appState.getValue("ar", 1) > 0;
		m_nbLaunches		= m_appState.getValue("nbLaunches", 1);

		OFAPPLOG->begin("");
		OFAPPLOG->println("- m_bLaunchFirstTime="+ofToString(m_bLaunchFirstTime));
		OFAPPLOG->println("- m_bARMode="+ofToString(m_bARMode));
		OFAPPLOG->println("- m_nbLaunches="+ofToString(m_nbLaunches));
		OFAPPLOG->end();

		
	}

	// APP : nb launches
	if (m_nbLaunches == 1)
	{
		m_timeShowAlert = 5.0f;
//		beginTimerForInfoAlert(); // <- will be launched when ok clicked (see viewController_ASide)
	}
	else if (m_nbLaunches<=3)
	{
		m_timeShowAlert = 30.0f;
		beginTimerForInfoAlert();
	}
	else
	{
		cancelTimerForInfoAlert();
	}
	
	increaseNbLaunches();

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

		// SCENE
		GLOBALS->setModel(&m_apparelModel);
		OFAPPLOG->println("- loading "+ modelObjName);
		if (m_apparelModel.load(modelObjName))
		{
			OFAPPLOG->println("- loaded 3d/" + modelObjName);
		}

		// MODS
		m_apparelModManager.forceModWeightAutomatic(true);
		m_apparelModManager.constructMods(&m_apparelModel);
		GLOBALS->setModManager(&m_apparelModManager);

		//mp_modPorcu = m_apparelModManager.getMod("Porcupinopathy");
		
		// SOUND
		m_soundInput.setup(0, 1);

		// NETWORK
		#if USE_OSC
		int oscPort = 1235;
		m_oscReceiver.setup(oscPort);
		m_oscReceiver.setModManager(&m_apparelModManager);
		OFAPPLOG->println("- osc receiver port = " + ofToString(oscPort));
		#endif
	
		// GUI
		mp_pageMain = new UIPageMain("PageMain",&m_uiManager);
		mp_pageMain->setApparelModManager(&m_apparelModManager);
		mp_pageMain->setup();

		// USER
		// > Templates
		setupTemplates();
		// > see update...

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
void ofApp::setupTemplates()
{
	OFAPPLOG->begin("ofApp::setupTemplates()");
	
	for (int i=0;i<3;i++)
	{
		user* pUser = m_userTemplate+i;
		pUser->setId(getTemplateUserId(i));
		pUser->setTemplate(true);
		pUser->setModManager(&m_apparelModManager);
		pUser->loadConfiguration();
		pUser->connect(); // connect to data.sql

	}
	OFAPPLOG->end();
}


//--------------------------------------------------------------
void ofApp::qcarInitARDone(NSError * error)
{
	OFAPPLOG->begin("ofApp::qcarInitARDone()");
	OFAPPLOG->println("setARMode("+ofToString(m_bARMode)+")");
	setARMode(m_bARMode);
	if (mp_pageMain)
		mp_pageMain->setQCARInit(true);

	m_bQCARInitDone = true;

	OFAPPLOG->end();
}


//--------------------------------------------------------------
void ofApp::setLaunchFirstTime(bool is)
{
	m_bLaunchFirstTime = is;
	saveAppState();
}

//--------------------------------------------------------------
void ofApp::setARMode(bool is)
{
	m_bARMode = is;
	if (mp_pageMain)
		mp_pageMain->setUseVuforia(is);
	saveAppState();
}

//--------------------------------------------------------------
void ofApp::increaseNbLaunches()
{
	m_nbLaunches++;
	saveAppState();
}

//--------------------------------------------------------------
void ofApp::setupUser()
{
	if (Twitter.sharedInstance.session != nil)
	{
		changeUser( Twitter.sharedInstance.session.userID.UTF8String );
		userTwitterGuestIOS* pTwitterIOS = (userTwitterGuestIOS*) m_user.getService("twitter");
		if (pTwitterIOS)
			pTwitterIOS->retrieveInfo();
	}
	else
	{
//		changeUser( "template01", true);
	}
}

//--------------------------------------------------------------
void ofApp::update()
{
	float dt = ofGetLastFrameTime();

	// Call this here otherwise Twitter loadUser won't work in setup
	if (m_doInitUser)
	{
		m_doInitUser = false;
		setupUser();
	}

	if (m_bQCARInitDone && m_bWillShowInfoAlert && m_bARMode && !mp_pageMain->hasFoundMarker())
	{
		m_timeShowAlert -= dt;
		if (m_timeShowAlert <= 0.0f)
		{
			AppAlert* pAlert = [[AppAlert alloc] init];
			[pAlert show];

	 		cancelTimerForInfoAlert();
		}
	}

	#if USE_OSC
	m_oscReceiver.update();
	#endif
	
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
void ofApp::deviceOrientationChanged(int newOrientation)
{
	
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

	if (bTemplate)
	{
		mp_userCurrent = getUserTemplate( userId );
		GLOBALS->setUser(mp_userCurrent);
		if (GLOBALS->mp_modSelfopathy)
			GLOBALS->mp_modSelfopathy->setImage( mp_userCurrent->getServicePropertyImage("twitter_image_object") );

		m_apparelModManager.countUserWords(mp_userCurrent);
	}
	else
	{


		m_user.deconnect();

		m_user.setId(userId);
		m_user.setTemplate(bTemplate);
		m_user.setModManager(&m_apparelModManager);
		m_user.createDirectory();
		m_user.loadConfiguration(); // create social interfaces (twitter) instance here, factory call setup on social interfaces (only if not template)
		m_user.useTick(bTemplate ? false : true);
		m_user.connect();

		m_apparelModManager.countUserWords(&m_user);

		mp_userCurrent = &m_user;
		GLOBALS->setUser(mp_userCurrent);
		if (GLOBALS->mp_modSelfopathy)
			GLOBALS->mp_modSelfopathy->setImage( mp_userCurrent->getServicePropertyImage("twitter_image_object") );
	}



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
	// Restore connected user
	if (templateIndex == -1)
	{
		m_templateIndexSelected = templateIndex;
		mp_userCurrent = &m_user;
		GLOBALS->setUser(mp_userCurrent);
		m_apparelModManager.countUserWords(mp_userCurrent);
	}
	else
	{
		m_templateIndexSelected = templateIndex;
		changeUser( getTemplateUserId(templateIndex), true  ) ; // id, isTemplate
	}
}

//--------------------------------------------------------------
user* ofApp::getUserTemplate(string id)
{
	user* pUser = 0;
	if (id == "__empty__")
	{
		pUser = &m_userEmpty;
	}
	else
	{
		for (int i=0;i<3;i++)
		{
			OFAPPLOG->println(ofToString(i)+" — "+m_userTemplate[i].getId()+" / "+id);
			if (m_userTemplate[i].getId() == id)
			{
				pUser = &m_userTemplate[i];
				break;
			}
		}
	}
	
	return pUser;

}

//--------------------------------------------------------------
void ofApp::onAlertInfoSwitch()
{
	OFAPPLOG->begin("ofApp::onAlertInfoSwitch()");

	setARMode(false);

	OFAPPLOG->end();
}







