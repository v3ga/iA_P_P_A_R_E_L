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

//--------------------------------------------------------------
userTwitterGuestIOS::userTwitterGuestIOS(user* pUser) : userSocialInterface("Twitter", pUser)
{
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
void userTwitterGuestIOS::doWork()
{
	OFAPPLOG->begin("userTwitterGuestIOS::doWork()");


	if ([Twitter sharedInstance].session != nil)
	{
		NSLog(@"%@",[Twitter sharedInstance].session.userName);

		NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
		NSDictionary *params = @{
					@"screen_name": [Twitter sharedInstance].session.userName,
       				@"count" : @"5", @"include_rts" : @"1"};
		NSError *clientError;

	    NSURLRequest *request =
		[[[Twitter sharedInstance] APIClient]
			URLRequestWithMethod:@"GET"
			URL:statusesShowEndpoint
       		parameters: params
			 error:&clientError
		];


		if (request)
		{

		  NSLog(@" making request ");
		  [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError)
		  {
			  NSLog(@" completion ");

			  if (data)
			  {
					NSString* nsJson=  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

					std::string tweets([nsJson UTF8String]);
					ofxJSONElement jtweets;
					if (jtweets.parse(tweets))
					{
						OFAPPLOG->println(" - found "+ofToString(jtweets.size()) + " tweets");
						int nbTweets = jtweets.size();
						string tweetText = "";
						string tweetId = "";
						for (int i=0;i<nbTweets;i++)
						{
							// Id
							tweetId = jtweets[i]["id_str"].asString();

							// Raw text
							tweetText = jtweets[i]["text"].asString();

							OFAPPLOG->println("  - "+ofToString(i)+". ["+ ofToString(tweetId) +"] - "+tweetText);

							mp_user->onNewText( tweetText );

							// Words
							vector<string> words = ofSplitString(tweetText, " ",true,true); // source, delimiter,ignoreEmpty,trim
		
							// Lower strings
							mp_user->onNewWords( words );
						}
					}
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




