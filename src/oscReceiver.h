//
//  oscReceiver.h
//  murmur
//
//  Created by Julien on 14/04/13.
//
//

#pragma once

#include "ofxOsc.h"
#include "oscDefs.h"
#include "apparelModManager.h"
#include "ofxAssimpModelLoader.h"

class oscReceiver  : public ofxOscReceiver
{
    public:
		oscReceiver			()
							{
								mp_modManager = 0;
							}
	
        void                update      ();
		void				setModManager(apparelModManager* pModManager){mp_modManager=pModManager;}
    
	private:
        ofxOscMessage		m_oscMessage;
		void				setParameterValue(ofAbstractParameter& param, ofxOscMessage& oscMsg, int oscArgIndex);


		apparelModManager*		mp_modManager;
		ofxAssimpModelLoader*	mp_modelCalibration;
 
		ofVec3f					m_modelCalibrationPositionBegin;
		ofVec3f					m_modelCalibrationScaleBegin;
};

