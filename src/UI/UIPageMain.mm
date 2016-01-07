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
	m_bDoDither				= false;
	m_sceneBufferScale		= 2;
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
	if ( m_shaderFlat.load("shaders/flat.vert", "shaders/flat.frag") )
	{
		OFAPPLOG->println( "- OK loaded flat shaders" );
	}
	else{
		OFAPPLOG->println( "- ERROR loaded flat shaders" );
	}


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
		m_meshFlat.setMode(OF_PRIMITIVE_TRIANGLES);
	
		 vector<ofMeshFaceApparel*>& meshFacesRef = pModel->getMeshFacesRef();
	
		ofMeshFaceApparel* pFace;
 
	 	for (int i=0; i<meshFacesRef.size();i++)
	 	{
			pFace 		= meshFacesRef[i];
	
			m_meshFlat.addVertex( pFace->getVertex(0) );
			m_meshFlat.addVertex( pFace->getVertex(1) );
			m_meshFlat.addVertex( pFace->getVertex(2) );

			m_meshFlat.addNormal( pFace->getFaceNormal() );
			m_meshFlat.addNormal( pFace->getFaceNormal() );
			m_meshFlat.addNormal( pFace->getFaceNormal() );
	
		}
	 }
}

//--------------------------------------------------------------
void UIPageMain::draw()
{
	// --------------------------------
	allocateSceneBuffer();
	


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
			ofxQCAR_Marker marker = qcar->getMarker();

        	ofEnableDepthTest();
	        ofSetColor(ofColor::white);
    	    ofSetLineWidth(1);
		 
	        qcar->begin();
				ofDrawAxis(40);
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
		}
		
		ofEnableDepthTest();
	    ofEnableBlendMode(OF_BLENDMODE_ALPHA);

		m_cam.setDistance(100);
		m_cam.begin();
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

//--------------------------------------------------------------
void UIPageMain::drawInfos()
{
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

		m_normalMatrix = ofMatrix4x4::getTransposedOf( ofMatrix4x4::getInverseOf(ofGetCurrentMatrix(OF_MATRIX_MODELVIEW)) );

//		glColorMask(false, false, false, false);
		glDepthMask(true);

		ofSetColor(0,255);
//		mp_apparelModel->drawFaces();

		   ofSetColor(0,255);
		   m_shaderFlat.begin();
		   m_shaderFlat.setUniformMatrix4f("normalMatrix", m_normalMatrix);
	 
//			pMod->drawFaces();
			m_meshFlat.draw();
		   m_shaderFlat.end();


		//glEnable(GL_CULL_FACE);
		glEnable(GL_POLYGON_OFFSET_FILL);
    	glPolygonOffset(-2,-2);

		glColorMask(true,true,true,true);
		//glDepthMask(true);

    	ofSetColor(255);
		vector<ofMeshFaceApparel*>&	faces = mp_apparelModel->getMeshFacesRef();
		int nbFaces = (int)faces.size();
		ofSetLineWidth(1);
		for (int i=0; i<nbFaces; i++)
		{
			ofMeshFaceApparel* pFace = faces[i];
	
	 		ofDrawLine(*pFace->getVertexPointer(0),*pFace->getVertexPointer(1));
	 		ofDrawLine(*pFace->getVertexPointer(1),*pFace->getVertexPointer(2));
	 		ofDrawLine(*pFace->getVertexPointer(2),*pFace->getVertexPointer(0));
		}

    	ofPopMatrix();
    	ofPopMatrix();

		glDisable(GL_POLYGON_OFFSET_FILL);
		glDisable(GL_CULL_FACE);
		ofSetLineWidth(1);

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


