//
//  UIManager.cpp
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/12/2014.
//
//

#include "UIManager.h"

//--------------------------------------------------------------
UIManager::UIManager()
{
	mp_currentPage = 0;
}

//--------------------------------------------------------------
UIManager::~UIManager()
{
	deletePages();
}


//--------------------------------------------------------------
void UIManager::setPageCurrent(UIPage* pPage)
{
	if (pPage != mp_currentPage){
		mp_currentPage = pPage;
	}
}

//--------------------------------------------------------------
void UIManager::createControls()
{
	int nbPages = m_listPages.size();
	for (int i=0; i<nbPages; i++)
	{
//		m_listPages[i]->createControls();
	}
}

//--------------------------------------------------------------
void UIManager::update(float dt)
{
	int nbPages = m_listPages.size();
	for (int i=0; i<nbPages; i++)
	{
		m_listPages[i]->update(dt);
	}
}

//--------------------------------------------------------------
void UIManager::draw()
{
	if (mp_currentPage)
		mp_currentPage->draw();
}

//--------------------------------------------------------------
void UIManager::addPage(UIPage* pPage)
{
   m_listPages.push_back(pPage);
}

//--------------------------------------------------------------
void UIManager::deletePages()
{
	m_listPages.clear();
	// not necessary to clear pointers as ofxUI manages them.
}

