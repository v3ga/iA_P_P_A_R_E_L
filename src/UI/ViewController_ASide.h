//
//  ViewController_ASide.h
//  Apparel 1.0
//
//  Created by Aurélien Michon on 16/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//


#import "ofxiOSViewController.h"

class ofApp;
@protocol ofAppDelegate <NSObject>
- (void) didPressButton:(ofApp *)controller;
@end


@interface ViewController_ASide : ofxiOSViewController<ofAppDelegate>


-(IBAction)setMood01:(id)sender;
-(IBAction)setMood02:(id)sender;
-(IBAction)setMood03:(id)sender;


@end
