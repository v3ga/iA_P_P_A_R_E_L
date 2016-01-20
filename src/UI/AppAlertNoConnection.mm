//
//  AppAlertNoConnection.m
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/01/2016.
//
//

#import "AppAlertNoConnection.h"


@implementation AppAlertNoConnection

//--------------------------------------------------------------
- (void) show
{
	UIAlertView *myAlert = [[UIAlertView alloc]
    	                        initWithTitle:@"Network Connection Unavailable"
        	                    message:@"Try connecting your device, or try templates offline."
            	                delegate:self
                	            cancelButtonTitle:@"OK"
                    	        otherButtonTitles:nil, nil];

	[myAlert show];
    [myAlert release];
}

//--------------------------------------------------------------
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

	if (buttonIndex == 0)
	{
        NSLog(@"user pressed OK");
    }
	
	[self release];
}




@end
