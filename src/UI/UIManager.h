//
//  UIManager.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/12/2014.
//
//

#pragma once
#include "ofMain.h"
#include "UIPage.h"

class UIManager
{
	public:
								UIManager		();
								~UIManager		();

		void					addPage			(UIPage*);
		void					setPageCurrent	(UIPage* pPageCurrent);


		void					createControls	();
		void					update			(float dt);
		void					draw			();

		vector<UIPage*>			m_listPages;

	private:
		void					deletePages		();

		UIPage*					mp_currentPage;
};
