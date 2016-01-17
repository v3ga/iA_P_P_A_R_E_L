//
//  UIPageMain.cpp
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/12/2014.
//
//

#include "UIPageMain.h"
#include "ofxQCAR.h"
#include "apparelModManager.h"
#include "globals.h"
#include "ofApparel.h"
#include "apparelMod.h"

//--------------------------------------------------------------
UIPageMain::UIPageMain(string id, UIManager* pManager) : UIPage(id, pManager)
{
	mp_apparelModel			= 0;
	mp_apparelModManager	= 0;
	m_bUseVuforia			= false;
	m_bDoDither				= true;
	m_sceneBufferScale		= 2;
	
	m_bQCARInit				= false;
	m_bQCARHasFoundMarker 	= false;
}

//--------------------------------------------------------------
void UIPageMain::setup()
{
	OFAPPLOG->begin("UIPageMain::setup()");
	if ( m_shaderDither.load("shaders/dither.vert", "shaders/dither.frag") )
	{
		OFAPPLOG->println( "- OK loaded dither shaders" );
	}
	else{
		OFAPPLOG->println( "- ERROR loaded dither shaders" );
	}
/*	if ( m_shaderFlat.load("shaders/flat.vert", "shaders/flat.frag") )
	{
		OFAPPLOG->println( "- OK loaded flat shaders" );
	}
	else{
		OFAPPLOG->println( "- ERROR loaded flat shaders" );
	}
*/

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void UIPageMain::update(float dt)
{
	// Update Vuforia
	ofxQCAR * qcar = ofxQCAR::getInstance();
	if (qcar)
		qcar->update();

	// Update A P P A R E L Model
	if (mp_apparelModManager)
		mp_apparelModManager->applyModChain();


	// --------------------------------
	apparelModel* pModel = mp_apparelModManager->getModelLastInChain();
	if (pModel)
	{

		m_meshFlat.clear();
		m_meshFlat.enableIndices();
		m_meshFlat.enableNormals();
		m_meshFlat.enableColors();
		m_meshFlat.setMode(OF_PRIMITIVE_TRIANGLES);
	
		vector<ofMeshFaceApparel*>& meshFacesRef = pModel->getMeshFacesRef();
		ofMeshFaceApparel* pFace;
		ofFloatColor vColor;
		float d=0.0f;
		ofVec3f Y(0.0f,1.0f,0.0f);
		ofVec3f n;
	 	for (int i=0; i<meshFacesRef.size();i++)
	 	{
			pFace 		= meshFacesRef[i];

			m_meshFlat.addVertex( *pFace->getVertexPointer(0) );
			m_meshFlat.addVertex( *pFace->getVertexPointer(1) );
			m_meshFlat.addVertex( *pFace->getVertexPointer(2) );
	
			n = pFace->getFaceNormal();


			m_meshFlat.addNormal( n );
			m_meshFlat.addNormal( n );
			m_meshFlat.addNormal( n );

			d = abs(Y.dot( n ));
	
			vColor.set(d,d,d);
			m_meshFlat.addColor( vColor );
			m_meshFlat.addColor( vColor );
			m_meshFlat.addColor( vColor );
		
		}
	 }
}

//--------------------------------------------------------------
void UIPageMain::draw()
{

	// --------------------------------
	allocateSceneBuffer();


	// Setup is called only when QCAR is initialized
	if (!m_bQCARInit)
	{
		ofBackground(0);
	}
	else
	{

		// MODE AUGMENTED REALITY
		// --------------------------------
		if (m_bUseVuforia)
		{
			ofxQCAR * qcar = ofxQCAR::getInstance();
			if (qcar == 0) return ;
		
			qcar->draw();

			if (m_bDoDither)
			{
				m_sceneBuffer.begin();
				ofClear(0);
			}
			
			if(qcar->hasFoundMarker())
			{
				if (!m_bQCARHasFoundMarker) m_bQCARHasFoundMarker = true;
			
			
				ofxQCAR_Marker marker = qcar->getMarker();

				ofEnableDepthTest();
				ofSetColor(ofColor::white);
				ofSetLineWidth(1);
			 
				qcar->begin();
					//ofDrawAxis(40);
					drawModel(marker.markerName);
				qcar->end();
		
				ofDisableDepthTest();
			}


			if (m_bDoDither)
			{
				m_sceneBuffer.end();
				drawDither();
			}

			drawInfos();
			
		}
		// MODE DEMO
		// --------------------------------
		else
		{
			if (m_bDoDither)
			{
				m_sceneBuffer.begin();
				ofClear(0);
				m_cam.begin( ofRectangle(0,0,m_sceneBuffer.getWidth(),m_sceneBuffer.getHeight()) );
			}
			else
			{
				m_cam.begin();
			}
			m_cam.setDistance(100);
			ofEnableDepthTest();
			ofEnableBlendMode(OF_BLENDMODE_ALPHA);



			drawModel();
			m_cam.end();

			ofDisableBlendMode();
			ofDisableDepthTest();

			if (m_bDoDither)
			{
				m_sceneBuffer.end();
				drawDither();
			}
		}

	}
}

//--------------------------------------------------------------
void UIPageMain::drawInfos()
{
/*
	ofPushMatrix();
	ofTranslate(20,20);
	ofScale(2,2);
	ofDrawBitmapStringHighlight(ofToString(GLOBALS->getSoundInputVolume()),0,0,ofColor(0),ofColor(255));
	ofPopMatrix();
	
	if (GLOBALS->getApp() && GLOBALS->getApp()->mp_modPorcu)
	{
		ofPushMatrix();
		ofTranslate(20,50);
		ofScale(2,2);
		if (GLOBALS->getApp()->mp_modPorcu->m_weight>0)
			ofDrawBitmapStringHighlight(ofToString(GLOBALS->getApp()->mp_modPorcu->m_weight),0,0,ofColor(0),ofColor(255));
		ofPopMatrix();
	}
*/

}

//--------------------------------------------------------------
void UIPageMain::drawDither()
{
	ofEnableAlphaBlending();

	m_shaderDither.begin();
	m_shaderDither.setUniformTexture( "src_tex_unit0" , m_sceneBuffer.getTexture(), 0 );

	ofTexture& tex = m_sceneBuffer.getTexture();

	float u = tex.getWidth() / ofNextPow2( tex.getWidth() );	// TODO : check this ?
	float v = tex.getHeight() / ofNextPow2( tex.getHeight() );

	ofMesh meshRenderFrame;
	float _width = ofGetWidth();
	float _height = ofGetHeight();

	meshRenderFrame.addVertex(ofVec3f(0,0,0));
	meshRenderFrame.addTexCoord(ofVec2f(0,0));

	meshRenderFrame.addVertex(ofVec3f(_width, 0, 0));
	meshRenderFrame.addTexCoord(ofVec2f(u, 0));

	meshRenderFrame.addVertex(ofVec3f(_width, _height, 0));
	meshRenderFrame.addTexCoord(ofVec2f(u, v));

	meshRenderFrame.addVertex(ofVec3f(0,_height, 0));
	meshRenderFrame.addTexCoord(ofVec2f(0,v));

	meshRenderFrame.addIndex(0);
	meshRenderFrame.addIndex(1);
	meshRenderFrame.addIndex(2);

	meshRenderFrame.addIndex(0);
	meshRenderFrame.addIndex(2);
	meshRenderFrame.addIndex(3);

	meshRenderFrame.enableTextures();
	meshRenderFrame.draw();


	m_shaderDither.end();

	ofDisableAlphaBlending();
}

//--------------------------------------------------------------
void UIPageMain::drawModel(string markerName)
{
	if (mp_apparelModManager == 0) return;

	mp_apparelModel = mp_apparelModManager->getModelLastInChain();
	
	if (mp_apparelModel)
	{
		ofPushMatrix();
		ofRotateX(-90);

		if (markerName == "marker_back_17")
		{
			ofRotateZ(180);
			ofTranslate(2.7,-30,-6);
		}


    	ofPushMatrix();
    	ofMultMatrix(mp_apparelModel->getModelMatrix());
		glDepthMask(true);

		ofSetColor(255,255);
		m_meshFlat.draw();

		mp_apparelModManager->drawModsExtra();

    	ofPopMatrix();
    	ofPopMatrix();
	}
}

//--------------------------------------------------------------
void UIPageMain::allocateSceneBuffer()
{
	if (!m_sceneBuffer.isAllocated() && m_bDoDither)
	{
		ofFbo::Settings settings;

		settings.width			= ofGetWidth() / m_sceneBufferScale;
		settings.height			= ofGetHeight() / m_sceneBufferScale;
		settings.internalformat	= GL_RGBA;
		settings.numSamples		= 0;
		settings.useDepth		= true;
		settings.useStencil		= false;
	    settings.textureTarget	= GL_TEXTURE_2D;

	   	m_sceneBuffer.allocate(settings);
	}

}


