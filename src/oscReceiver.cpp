//
//  oscReceiver.cpp
//  murmur
//
//  Created by Julien on 14/04/13.
//
//

#include "oscReceiver.h"
#include "globals.h"
#include "apparelModManager.h"
#include "apparelMod.h"
#include "apparelModel.h"

#define APPAREL_LOG_OSC	1

//--------------------------------------------------------------
void oscReceiver::update()
{
    if (hasWaitingMessages())
    {
		while(getNextMessage(&m_oscMessage))
		{
            // int indexArg = 0;
			ofLog() << "oscReceiver::update() - received " << m_oscMessage.getAddress();


			if (m_oscMessage.getAddress() == OSC_MOD_SET_WEIGHT)
			{
				apparelModManager* pModManager = GLOBALS->getModManager();
				if (pModManager)
				{
					// Name of the mod
					string instanceName = m_oscMessage.getArgAsString(0);

					// Get Mod instance
					apparelMod* pMod = pModManager->getMod(instanceName);

					// Exists ??
					if (pMod && pMod->m_isWeightManual)
					{
						pMod->setWeight( m_oscMessage.getArgAsFloat(1) );
					}
				}
			}


			else if (m_oscMessage.getAddress() == OSC_MOD_SET_PARAMETER)
			{
				apparelModManager* pModManager = GLOBALS->getModManager();
				if (pModManager)
				{
					string instanceName = m_oscMessage.getArgAsString(0);
					apparelMod* pMod = pModManager->getMod(instanceName);
					if (pMod)
					{
						if (m_oscMessage.getNumArgs() == 3)
						{
							string parameterName = m_oscMessage.getArgAsString(1);
							#if APPAREL_LOG_OSC
							OFAPPLOG->println("[OSC] instanceName="+instanceName+"/parameterName="+parameterName);
					 		#endif
							ofAbstractParameter& modParam = pMod->getParameter(parameterName);
							setParameterValue(modParam, m_oscMessage, 2);
							pMod->onParameterChanged(modParam);
							pMod->saveParameters();
						
							#if APPAREL_LOG_OSC
							OFAPPLOG->println("[OSC] value for "+instanceName+"/"+parameterName+"="+modParam.toString());
							#endif
						}
						else if (m_oscMessage.getNumArgs() == 4)
						{
						  string groupName = m_oscMessage.getArgAsString(1);
						  string parameterName = m_oscMessage.getArgAsString(2);
						  ofAbstractParameter& modGroupParam = pMod->getParameter(groupName);
						  if (modGroupParam.type()==typeid(ofParameterGroup).name())
						  {
							  setParameterValue(modGroupParam, m_oscMessage, 3);
							  pMod->onParameterChanged(modGroupParam);
							  pMod->saveParameters();
							  
							  #if APPAREL_LOG_OSC
							  OFAPPLOG->println("[OSC] value for "+instanceName+"/groupName="+groupName+",parameterName ="+parameterName);
							  #endif
						  }
						}

					}



				}
	   		}
			else if (m_oscMessage.getAddress() == OSC_MOD_SET_MODEL)
			{
				apparelModManager* pModManager = GLOBALS->getModManager();
				if (pModManager)
				{
					string instanceName = m_oscMessage.getArgAsString(0);
//					OFAPPLOG->println("instanceName="+instanceName);
					apparelMod* pMod = pModManager->getMod(instanceName);
					if (pMod)
					{
						string xmlModel = m_oscMessage.getArgAsString(1);
						pMod->loadModel(xmlModel);
					}
				}

			}
			else
			if (m_oscMessage.getAddress() == OSC_MOD_EMPTY_USER_DATA_SQL)
			{
				apparelModManager* pModManager = GLOBALS->getModManager();
				if (pModManager)
				{
					string instanceName = m_oscMessage.getArgAsString(0);
					apparelMod* pMod = pModManager->getMod(instanceName);
					if (pMod)
					{
						pMod->resetWordsCountUserDatabase( GLOBALS->getUser(), true);
					}
				}
			}

/*
			else if (m_oscMessage.getAddress() == OSC_MODEL_SET_CALIBRATION_BEGIN)
			{
				mp_modelCalibration = GLOBALS->getModel();
				m_modelCalibrationPositionBegin = mp_modelCalibration->getPosition();
				m_modelCalibrationScaleBegin = mp_modelCalibration->getScale();
			}
			else if (m_oscMessage.getAddress() == OSC_MODEL_SET_CALIBRATION)
			{
				if (mp_modelCalibration)
				{
					float x = m_oscMessage.getArgAsFloat(0);
					float y = m_oscMessage.getArgAsFloat(1);
					float z = m_oscMessage.getArgAsFloat(2);
					float s = m_oscMessage.getArgAsFloat(3);

					ofVec3f newPosition = m_modelCalibrationPositionBegin+ofVec3f(x,y,z);
					ofVec3f newScale = m_modelCalibrationScaleBegin+ofVec3f(s,s,s);

					mp_modelCalibration->setPosition( newPosition.x,newPosition.y,newPosition.z  );
					mp_modelCalibration->setScale(newScale.x,newScale.y,newScale.z);
				}
			}
			else if (m_oscMessage.getAddress() == OSC_MODEL_SET_CALIBRATION_END)
			{
				mp_modelCalibration = 0;
			}
			else if (m_oscMessage.getAddress() == OSC_MODEL_SAVE_CALIBRATION)
			{
				// TODO : get the model name (arg 0)
				apparelModel* pModel = GLOBALS->getModel();
				if (pModel)
					pModel->saveProperties();
			}
*/
 
		}
	}
}

void oscReceiver::setParameterValue(ofAbstractParameter& param, ofxOscMessage& msg, int oscArgIndex)
{
	ofAbstractParameter* p = &param;

	if(p->type()==typeid(ofParameter<int>).name() && msg.getArgType(oscArgIndex)==OFXOSC_TYPE_INT32){
	   p->cast<int>() = msg.getArgAsInt32(oscArgIndex);
   }else if(p->type()==typeid(ofParameter<float>).name() && msg.getArgType(oscArgIndex)==OFXOSC_TYPE_FLOAT){
	   p->cast<float>() = msg.getArgAsFloat(oscArgIndex);
   }else if(p->type()==typeid(ofParameter<bool>).name() && msg.getArgType(oscArgIndex)==OFXOSC_TYPE_INT32){
	   p->cast<bool>() = msg.getArgAsInt32(oscArgIndex);
   }else if(msg.getArgType(oscArgIndex)==OFXOSC_TYPE_STRING){
	   p->fromString(msg.getArgAsString(oscArgIndex));
   }

}

