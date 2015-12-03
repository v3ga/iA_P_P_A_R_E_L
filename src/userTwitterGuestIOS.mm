//
//  userTwitterGuestIOS.cpp
//  A_P_P_A_R_E_L
//
//  Created by Julien on 16/07/2014.
//
//

#include "userTwitterGuestIOS.h"
#include "ofAppLog.h"
#include "ofxJSONElement.h"

#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>


//----------------------------------------
int64_t ofToInt64(const string& intString) {
	int64_t x = 0;
	istringstream cur(intString);
	cur >> x;
	return x;
}

//--------------------------------------------------------------
userTwitterGuestIOS::userTwitterGuestIOS(user* pUser) : userSocialInterface("twitter", pUser)
{
	m_nbFollowers 	= 0;
	m_nbFollowing	= 0;
	
	m_bDoAnalyzeData = false;
	m_bAnalysingData = false;
	
	m_bSetup = false;
	
	m_lastTweetId = 0;
	
	//m_imageLoader.startThread();
}

//--------------------------------------------------------------
bool userTwitterGuestIOS::setup(ofxXmlSettings* pConfig, int serviceIndex)
{
	OFAPPLOG->begin("userTwitterGuestIOS::setup");

	// TEMP
	getUser()->useThread(false);

	OFAPPLOG->end();
	return true;
}

//--------------------------------------------------------------
void userTwitterGuestIOS::retrieveInfo()
{
	OFAPPLOG->begin("userTwitterGuestIOS::retrieveInfo()");
	TWTRSession* session = [[Twitter sharedInstance] session];

	if (session != nil && m_bSetup == false)
	{
		OFAPPLOG->begin(" - ok session there & not set up");
		NSLog(@"- user id = %@", [session userID]);
	  /* Get user info */
	  [[[Twitter sharedInstance] APIClient] loadUserWithID:[session userID] completion:^(TWTRUser *userTwitter, NSError *error)
	  {
		  OFAPPLOG->begin(" - loadUserWithID called");
		 if (![error isEqual:nil])
		 {
			// Get infos
			user* pUser = mp_user;
			if (pUser)
			{
				// TEMP ?
				pUser->useThread(false);
				

			 	// Last tweet ID
				readLastTweetId();
			 
				// Image URLs
				setImageMiniUrl( [[userTwitter profileImageMiniURL] UTF8String] );
				setImageLargeUrl( [[userTwitter profileImageLargeURL] UTF8String] );

				// Followers / following
				// https://dev.twitter.com/rest/reference/get/users/show
				// https://docs.fabric.io/ios/twitter/access-rest-api.html
			 
				TWTRAPIClient* client = [[Twitter sharedInstance] APIClient];
				NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/show.json";
				NSDictionary *params = @{@"user_id" : [session userID]};
				NSError *clientError;

			   NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];

			   if (request)
			   {
				   [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError)
				   {
					   if (data)
					   {
						  NSString* nsJson=  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
						  if (nsJson != nil)
						  {
							  std::string json([nsJson UTF8String]);
							  parseUserInfo(json);
							  m_bSetup = true;
						  }
					   }
					   else
					   {
						   NSLog(@"Error: %@", connectionError);
					   }
				   }];
			   }
			   else
			   {
				   NSLog(@"Error: %@", clientError);
			   }
		   	}
		  }
		  else
		  {
			  NSLog(@"Twitter error getting profile : %@", [error localizedDescription]);
		  }
	  }];
   }
   OFAPPLOG->end();
}

//--------------------------------------------------------------
void userTwitterGuestIOS::doWork()
{
	OFAPPLOG->begin("userTwitterGuestIOS::doWork()");

	if ([Twitter sharedInstance].session != nil && !m_bAnalysingData)
	{
		// NSLog(@"%@",[Twitter sharedInstance].session.userName);

		NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
		
		// TODO : implement since_id variable in request
		// https://dev.twitter.com/rest/reference/get/statuses/user_timeline
		
		NSDictionary *params ;
	 
		if (m_lastTweetId==0)
		{
		  params = @{
					@"screen_name": [Twitter sharedInstance].session.userName,
					@"count" : @"10",
					@"include_rts" : @"1"
			 };
		}
		else
		{
		  params = @{
					@"screen_name": [Twitter sharedInstance].session.userName,
					@"count" : @"5",
					@"include_rts" : @"1",
			 		@"since_id" : [NSString stringWithFormat:@"%lld", m_lastTweetId]
			 };
		}
	 
		NSError *clientError;

	    NSURLRequest *request =
		[[[Twitter sharedInstance] APIClient]
			URLRequestWithMethod:		@"GET"
			URL:						statusesShowEndpoint
       		parameters: 				params
			error:						&clientError
		];


		if (request)
		{
		  m_tweetsLatest = "";

		  //NSLog(@" making request ");
		  [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError)
		  {
			  //NSLog(@" completion ");

			  if (data)
			  {
					NSString* nsJson=  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
					m_tweetsLatest = [nsJson UTF8String];
					m_bDoAnalyzeData = true;
			  }
			  else {
				  NSLog(@"Error: %@", connectionError);
			  }
		  }];
		}
		else
		{
			 NSLog(@"Error: no request");
		}
	}

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void userTwitterGuestIOS::update(float dt)
{
	if (m_bDoAnalyzeData)
	{
		OFAPPLOG->begin("userTwitterGuestIOS::update(), m_bDoAnalyzeData = true");
		m_bDoAnalyzeData = false;
		m_bAnalysingData = true;
		startThread(false);

//		[self performSelectorInBackground:@selector(saySomething) withObject:nil];

		OFAPPLOG->end();
	}
}

//--------------------------------------------------------------
void userTwitterGuestIOS::threadedFunction()
{
	analyzeData();

	m_bAnalysingData = false;
}
//--------------------------------------------------------------
void userTwitterGuestIOS::analyzeData()
{
	if (m_tweetsLatest == "" || mp_user == 0) return;

   std::string tweets = m_tweetsLatest;
   
   ofxJSONElement jtweets;
   if (jtweets.parse(tweets))
   {
	   OFAPPLOG->println(" - found "+ofToString(jtweets.size()) + " tweets");
	   int nbTweets = jtweets.size();
	   string tweetText = "";
	   string tweetId = "";
	   uint64_t tweetId2 = 0;
	   for (int i=0;i<nbTweets;i++)
	   {
		   // Id
		   tweetId = jtweets[i]["id_str"].asString();
		   tweetId2 = jtweets[i]["id"].asInt64();

		   // Raw text
		   tweetText = jtweets[i]["text"].asString();

		   // Words
		   vector<string> words = ofSplitString(tweetText, " ",true,true); // source, delimiter,ignoreEmpty,trim

		   OFAPPLOG->println("  - "+ofToString(i)+". ["+ ofToString(tweetId) +"] - "+tweetText);

		   mp_user->onNewWords( words );


			if (tweetId2 > m_lastTweetId){
				m_lastTweetId = tweetId2;
			}
	   }

	   if (nbTweets>0 && m_lastTweetId>0)
			writeLastTweetId();
   }
}


//--------------------------------------------------------------
void userTwitterGuestIOS::loadData()
{
	OFAPPLOG->begin("userTwitterGuestIOS::loadData()");
/*
	if (mp_user)
	{
		// Create user twitter directory if it does not exist
		#ifdef TARGET_OF_IOS
			string pathDirUserTwitter = mp_user->getPathDocument("twitter");
			ofDirectory dirUserTwitter( pathDirUserTwitter );
			if (!dirUserTwitter.exists()){
				if (dirUserTwitter.create()){
					OFAPPLOG->begin("creating '"+pathDirUserTwitter+"'");
				}
			}
		#endif


		string pathData = mp_user->getPathDocument("twitter/data.xml");
		OFAPPLOG->println("-loading "+pathData);

		ofxXmlSettings data;
		if (data.load(pathData))
		{
			OFAPPLOG->println("-loaded");
			m_tweetLastId_str = data.getValue("tweetLastId", "-1");
			OFAPPLOG->println("m_tweetLastId_str="+m_tweetLastId_str);
		}else{ OFAPPLOG->println("-error loading file"); }
	}
*/
	OFAPPLOG->end();
}

//--------------------------------------------------------------
void userTwitterGuestIOS::saveData()
{
	OFAPPLOG->begin("userTwitterGuestIOS::saveData()");

	if (mp_user)
	{
/*
		string pathData = mp_user->getPathDocument("twitter/data.xml");

		OFAPPLOG->println("-path="+pathData);
		
		ofxXmlSettings data;
		data.addTag("tweetLastId");
		data.setValue("tweetLastId", m_tweetLastId_str);
		if ( data.save(pathData) ){
			OFAPPLOG->println("-saving done");
		}else{
			OFAPPLOG->println(OF_LOG_ERROR, "-saving error");
		}
*/
	}

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void userTwitterGuestIOS::setImageMiniUrl(string url)
{
	OFAPPLOG->println("userTwitterGuestIOS::setImageMiniUrl('"+url+"')");
	m_imageMiniUrl = url;
	//loadImageMini();
}

//--------------------------------------------------------------
void userTwitterGuestIOS::setImageLargeUrl(string url)
{
	OFAPPLOG->println("userTwitterGuestIOS::setImageLargeUrl('"+url+"')");
	m_imageLargeUrl = url;
}

//--------------------------------------------------------------
void userTwitterGuestIOS::setFollowersFollowing(int followers, int following)
{
	OFAPPLOG->println("userTwitterGuestIOS::setFollowersFollowing("+ofToString(followers)+","+ofToString(following)+")");
	m_nbFollowers = followers;
	m_nbFollowing = following;
}

//--------------------------------------------------------------
void userTwitterGuestIOS::parseUserInfo(string str)
{
	ofxJSONElement json;
	bool parseOk = json.parse(str);
	if (parseOk)
	{
		int followers = json["followers_count"].asInt();
		int following = json["friends_count"].asInt();
		
		setFollowersFollowing(followers, following);
	}
}

//--------------------------------------------------------------
void userTwitterGuestIOS::loadImageMini()
{
	if (m_imageMiniUrl != "")
		m_imageLoader.loadFromURL( m_imageMini, m_imageMiniUrl );
}

//--------------------------------------------------------------
void userTwitterGuestIOS::loadImageLarge()
{
	if (m_imageLargeUrl != "")
		m_imageLoader.loadFromURL( m_imageLarge, m_imageLargeUrl );
}

//--------------------------------------------------------------
void userTwitterGuestIOS::readLastTweetId()
{
	OFAPPLOG->begin("userTwitterGuestIOS::readLastTweetId()");
	if (mp_user)
	{
		string path = mp_user->getPathDocument("twitter_last_tweet.xml");
		ofxXmlSettings data;
		if (data.load(path))
		{
			m_lastTweetId = ofToInt64(data.getValue("id", "0"));
			OFAPPLOG->println(" - m_lastTweetId ="+ofToString(m_lastTweetId));
		}
		else
		{
			OFAPPLOG->println(" - error loading "+path);
		}
	}
	OFAPPLOG->end();
}

//--------------------------------------------------------------
void userTwitterGuestIOS::writeLastTweetId()
{
	OFAPPLOG->begin("userTwitterGuestIOS::readLastTweetId()");
	OFAPPLOG->println(" - m_lastTweetId ="+ofToString(m_lastTweetId));
	
	string path = mp_user->getPathDocument("twitter_last_tweet.xml");
	ofxXmlSettings data;
	data.setValue("id", ofToString(m_lastTweetId));
	if (data.save(path))
	{
		OFAPPLOG->println(" - ok saved "+path);
	}
	else
	{
		OFAPPLOG->println(" - error saving "+path);
	}
	
	OFAPPLOG->end();
}







