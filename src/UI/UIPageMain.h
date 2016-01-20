//
//  UIPageMain.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/12/2014.
//
//

#pragma once
#include "UIPage.h"
#include "apparelModel.h"

class apparelModManager;

class UIPageMain : public UIPage
{
	public:
		UIPageMain		(string id, UIManager* pManager);

		void					setApparelModManager(apparelModManager* p){mp_apparelModManager = p;}
		void					setUseVuforia		(bool is=true){m_bUseVuforia = is;}

		void					setup				();
		void					update				(float dt);
		void					draw				();

		void					drawModel			(string markerName="");
		void					drawDither			();
		void					drawInfos			();
 
		void					setQCARInit			(bool is=true){m_bQCARInit=is;}
		bool					hasFoundMarker		(){return m_bQCARHasFoundMarker;}

	private:
		bool					m_bUseVuforia;
		ofEasyCam 				m_cam;
		apparelModel			m_apparelModel;
		apparelModel*			mp_apparelModel;
		apparelModManager*		mp_apparelModManager;
 
		ofMesh					m_meshExtra;

		ofFbo					m_sceneBuffer;
		float					m_sceneBufferScale; // relative to screen

		ofShader				m_shaderDither;
		bool					m_bDoDither;

		ofShader				m_shaderFlat;
		ofMesh					m_meshFlat;
		ofMatrix4x4				m_normalMatrix;

		bool					m_bQCARInit;
		bool					m_bQCARHasFoundMarker;


		void					allocateSceneBuffer	();
};


