//
//  ViewController_ASide.m
//  Apparel 1.0
//
//  Created by Aurélien Michon on 16/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//

#import "ViewController_ASide.h"
#import "ofApparel.h"

//--------------------------------------------------------------
@interface ViewController_ASide ()

@end

//--------------------------------------------------------------
@implementation ViewController_ASide

- (IBAction)unwindToASide:(UIStoryboardSegue *)unwindSegue
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
    // Do any additional setup after loading the view.
}

//--------------------------------------------------------------
//http://forum.openframeworks.cc/t/hardware-orientation-on-startup-for-ios-with-of-develop/12939/5
- (id)initWithFrame:(CGRect)frame app:(ofxiOSApp *)app
{
    self = [super initWithFrame:frame app:app];
    self.glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return self;
}

//--------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    
    NSLog(@"ViewController_ASide view loaded");

    // initialise a new OF app when view is loading
    ofApp* myApp = new ofApp();
    [self initWithFrame:[[UIScreen mainScreen] bounds] app:myApp ];
}


//--------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    ofxiOSSendGLViewToBack();
}


//--------------------------------------------------------------
-(IBAction)setMood01:(id)sender
{
    NSLog(@"ViewController_ASide setMood01");
	ofApp* pApp = (ofApp*) ofGetAppPtr();
	if (pApp)
	{
		pApp->onMoodSelected(0);
	}
}

//--------------------------------------------------------------
- (IBAction)unsetMood01:(id)sender
{
    NSLog(@"ViewController_ASide unsetMood01");
	ofApp* pApp = (ofApp*) ofGetAppPtr();
	if (pApp)
	{
		pApp->onMoodUnselect();
	}
}

//--------------------------------------------------------------
-(IBAction)setMood02:(id)sender
{
    NSLog(@"ViewController_ASide setMood02");
	ofApp* pApp = (ofApp*) ofGetAppPtr();
	if (pApp)
	{
		pApp->onMoodSelected(1);
	}
}

//--------------------------------------------------------------
- (IBAction)unsetMood02:(id)sender
{
    NSLog(@"ViewController_ASide unsetMood02");
	ofApp* pApp = (ofApp*) ofGetAppPtr();
	if (pApp)
	{
		pApp->onMoodUnselect();
	}
}


//--------------------------------------------------------------
-(IBAction)setMood03:(id)sender
{
    NSLog(@"ViewController_ASide setMood03");
	ofApp* pApp = (ofApp*) ofGetAppPtr();
	if (pApp)
	{
		pApp->onMoodSelected(2);
	}
}

//--------------------------------------------------------------
- (IBAction)unsetMood03:(id)sender {
    NSLog(@"ViewController_ASide unsetMood03");
	ofApp* pApp = (ofApp*) ofGetAppPtr();
	if (pApp)
	{
		pApp->onMoodUnselect();
	}
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

//--------------------------------------------------------------
-(IBAction)selectAROn:(id)sender
{
}

//--------------------------------------------------------------
-(IBAction)selectAROff:(id)sender
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
