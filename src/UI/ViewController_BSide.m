//
//  ViewController_BSide.m
//  Apparel 1.0
//
//  Created by Aurélien Michon on 16/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//

#import "ViewController_BSide.h"
#import <TwitterKit/TwitterKit.h>

@interface ViewController_BSide ()

@end

@implementation ViewController_BSide

- (IBAction)unwindToBSide:(UIStoryboardSegue *)unwindSegue
{
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        // play with Twitter session
    }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];

    
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
