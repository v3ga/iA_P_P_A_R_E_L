//
//  ViewController_BSide.m
//  Apparel 1.0
//
//  Created by Aurélien Michon on 16/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//

#import "ViewController_BSide.h"
#import <TwitterKit/TwitterKit.h>
#include "ofApp.h"
#include "user.h"
#include "userTwitterGuestIOS.h"
#include "Globals.h"

//--------------------------------------------------------------
@interface ViewController_BSide ()
@end

//--------------------------------------------------------------
@implementation ViewController_BSide

//--------------------------------------------------------------
- (IBAction)unwindToBSide:(UIStoryboardSegue *)unwindSegue
{
}

//--------------------------------------------------------------
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//--------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;


	TWTRSession* session = [[Twitter sharedInstance] session];
	if (session == nil)
	{
		// https://twittercommunity.com/t/can-we-customize-the-twitter-sign-in-button-with-fabric/27880
	    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error)
		{
	        // TODO : play with Twitter session
			// http://stackoverflow.com/questions/29120055/how-to-get-profile-url-of-the-logged-in-user-with-twitter-kit-fabric-ios
			if (![error isEqual:nil])
			{
				[self retrieveUserInfo:session];
			}
    	}];
    	logInButton.center = self.view.center;
    	[self.view addSubview:logInButton];
	}
	else
	{
		[self retrieveUserInfo:session];
	}
}

//--------------------------------------------------------------
-(void) retrieveUserInfo: (TWTRSession*) session
{
 	NSLog(@"Twitter signed in as -> name = %@ id = %@ ", [session userName],[session userID]);

   /* Get user info */
   [[[Twitter sharedInstance] APIClient] loadUserWithID:[session userID] completion:^(TWTRUser *userTwitter, NSError *error)
   {
	  if (![error isEqual:nil])
	  {
		  ofApp* pApp = (ofApp*) ofGetAppPtr();
		  if (pApp)
		  {
			  // Application change user
			  pApp->changeUser( [[session userID] UTF8String], false );

			  // Get infos
			  user* pUser = GLOBALS->getUser();
			  if (pUser)
			  {
				  // TEMP ?
				  pUser->useThread(false);
			   
				  // Get twitter service
				  userTwitterGuestIOS* pUserTwitter = (userTwitterGuestIOS*) pUser->getService("Twitter");
				  if (pUserTwitter)
				  {
					  // Image URLs
					  pUserTwitter->setImageMiniUrl( [[userTwitter profileImageMiniURL] UTF8String] );
					  pUserTwitter->setImageLargeUrl( [[userTwitter profileImageLargeURL] UTF8String] );

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
									pUserTwitter->parseUserInfo(json);
									pUserTwitter->m_bSetup = true;
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
		   }
	   }
	   else {
		   NSLog(@"Twitter error getting profile : %@", [error localizedDescription]);
	   }
   }];
}

//--------------------------------------------------------------
-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

//--------------------------------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField setReturnKeyType:UIReturnKeyDone];
    // Submit Data from done
    //
    // Then close the keyboard
    //[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [textField resignFirstResponder];
    return YES;
}

//--------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------
-(IBAction)selectTemplate01:(id)sender
{
}

//--------------------------------------------------------------
-(IBAction)selectTemplate02:(id)sender
{
}

//--------------------------------------------------------------
-(IBAction)selectTemplate03:(id)sender
{
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
