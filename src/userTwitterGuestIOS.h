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

class userTwitterGuestIOS : public userSocialInterface, public ofThread
{
	public:
			userTwitterGuestIOS					(user*);
	
			bool			setup				(ofxXmlSettings* pConfig, int serviceIndex);
			void			update				(float dt);
			void			doWork				();
			void			analyzeData			();
			void			loadData			();
			void			saveData			();
 
			void			retrieveInfo		();
 
			void			setImageMiniUrl		(string url);
			void			setImageLargeUrl	(string url);
 
			void			loadImageMini		();
			void			loadImageLarge		();
 
			void			setFollowersFollowing(int followers, int following);
			void			parseUserInfo(string json);
 
			void			threadedFunction	();

	protected:
			string					m_tweetsLatest;

			int						m_nbFollowers, m_nbFollowing;
			string					m_imageMiniUrl;
			string					m_imageLargeUrl;

 
			ofImage					m_imageMini;
			ofImage					m_imageLarge;
			ofxThreadedImageLoader	m_imageLoader;
 
			bool					m_bDoAnalyzeData;
			bool					m_bAnalysingData;
};
