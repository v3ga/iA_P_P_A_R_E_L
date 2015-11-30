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
			// http://stackoverflow.com/questions/29120055/how-to-get-profile-url-of-the-logged-in-user-with-twitter-kit-fabric-ios
			if (![error isEqual:nil])
			{
				[self changeUserAndRetrieveInfoUser:session];
			}
    	}];
    	logInButton.center = self.view.center;
    	[self.view addSubview:logInButton];
	}
	else
	{
		//[self retrieveUserInfo:session];
	}
}

//--------------------------------------------------------------
-(void) changeUserAndRetrieveInfoUser: (TWTRSession*) session
{
 	NSLog(@"Twitter signed in as -> name = %@ id = %@ ", [session userName],[session userID]);
	ofApp* pApp = GLOBALS->getApp();
	if (pApp)
	{
		pApp->changeUser( [[session userID] UTF8String] );
		
		user* pUser = GLOBALS->getUser();
		if (pUser)
		{
			userTwitterGuestIOS* pTwitterIOS = (userTwitterGuestIOS*) pUser->getService("twitter");
			if (pTwitterIOS) pTwitterIOS->retrieveInfo();
		}
	}
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
	GLOBALS->getApp()->onTemplateSelected(0);
}

//--------------------------------------------------------------
-(IBAction)selectTemplate02:(id)sender
{
	GLOBALS->getApp()->onTemplateSelected(1);
}

//--------------------------------------------------------------
-(IBAction)selectTemplate03:(id)sender
{
	GLOBALS->getApp()->onTemplateSelected(2);
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
