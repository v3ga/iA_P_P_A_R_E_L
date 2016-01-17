//
//  MyAppDelegate.m
//  emptyExample
//
//  Created by lukasz karluk on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAppDelegate.h"
//#import "MyAppViewController.h"

//#import "ofxQCAR_ViewController.h"
#import "ofApparel.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
@implementation MyAppDelegate

@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [super applicationDidFinishLaunching: application];
    
    /**
     *
     *  Below is where you insert your own UIViewController and take control of the App.
     *  In this example im creating a UINavigationController and adding it as my RootViewController to the window. (this is essential)
     *  UINavigationController is handy for managing the navigation between multiple view controllers, more info here,
     *  http://developer.apple.com/library/ios/#documentation/uikit/reference/UINavigationController_Class/Reference/Reference.html
     *
     *  I then push MyAppViewController onto the UINavigationController stack.
     *  MyAppViewController is a custom view controller with a 3 button menu.
     *
     **/
/*
    self.navigationController = [[[UINavigationController alloc] init] autorelease];
    [self.navigationController pushViewController:[[[MyAppViewController alloc] init] autorelease]
                                         animated:YES];

    [self.window setRootViewController:self.navigationController];
    
    //--- style the UINavigationController
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.topItem.title = @"ofxQCAR";
  */
 
 /*
	ofxQCAR_ViewController * viewController;  
    viewController = [[[ofxQCAR_ViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]  
                                                                app:new ofApp()] autorelease];

    [self.window setRootViewController:viewController];  

    //[viewController release];
*/


	// http://pinkstone.co.uk/how-to-load-a-different-storyboard-depending-on-screen-size-in-ios/
	// https://github.com/versluis/ScreenSize/blob/master/ScreenSize/AppDelegate.m
	

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    navigationController = [[storyboard instantiateInitialViewController] retain];
    [self.window setRootViewController:self.navigationController];
 
	[Fabric with:@[TwitterKit]];

    return YES;
}

// drop in replacement for ofxiOSGetViewController() as glViewController = nil
- (UIViewController*) getViewController {
    return [self.navigationController visibleViewController];
}

- (void) dealloc {
    self.navigationController = nil;
    [ super dealloc ];
}

@end
