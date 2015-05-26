//
//  userTwitterGuestIOS.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 21/03/2015.
//
//

#pragma once

#include "userSocialInterface.h"

class userTwitterGuestIOS : public userSocialInterface
{
	public:
			userTwitterGuestIOS					(user*);
	
			bool			setup				(ofxXmlSettings* pConfig, int serviceIndex);
			void			doWork				();
			void			loadData			();
			void			saveData			();

	protected:
	
//			TWTRSession* 	mp_session;
};
