//
//  ViewController_BSide.h
//  Apparel 1.0
//
//  Created by Aurélien Michon on 16/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>


@interface ViewController_BSide : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

-(void) changeUserAndRetrieveInfoUser: (TWTRSession*) session;

-(IBAction)selectTemplate01:(id)sender;
-(IBAction)selectTemplate02:(id)sender;
-(IBAction)selectTemplate03:(id)sender;

-(IBAction)selectAROn:(id)sender;
-(IBAction)selectAROff:(id)sender;


@end