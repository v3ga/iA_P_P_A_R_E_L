//
//  UIPage.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/12/2014.
//
//

#pragma once
#include "ofMain.h"

class UIManager;
class UIPage
{
	public:
		UIPage						(string id, UIManager* pManager)
		{
			m_id 		= id;
			mp_uiManager= pManager;
		}

		string			getId			(){return m_id;}

		virtual	void	update			(float dt){}
		virtual	void	draw			(){}


	protected:
		string			m_id;
		UIManager*		mp_uiManager;

};
