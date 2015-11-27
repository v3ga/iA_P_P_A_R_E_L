//
//  userTwitterGuestIOS.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 21/03/2015.
//
//

#pragma once

#include "userSocialInterface.h"
#include "ofxThreadedImageLoader.h"

class userTwitterGuestIOS : public userSocialInterface
{
	public:
			userTwitterGuestIOS					(user*);
	
			bool			setup				(ofxXmlSettings* pConfig, int serviceIndex);
			void			doWork				();
			void			loadData			();
			void			saveData			();
 
			void			setImageMiniUrl		(string url);
			void			setImageLargeUrl	(string url);
 
			void			loadImageMini		();
			void			loadImageLarge		();
 
			void			setFollowersFollowing(int followers, int following);
			void			parseUserInfo(string json);

	protected:
			int				m_nbFollowers, m_nbFollowing;
			string			m_imageMiniUrl;
			string			m_imageLargeUrl;
 
 
			ofImage			m_imageMini;
			ofImage			m_imageLarge;
 
			ofxThreadedImageLoader	m_imageLoader;
	
	
//			TWTRSession* 	mp_session;
};
