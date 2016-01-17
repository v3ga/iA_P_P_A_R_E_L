//
//  AppAlert.m
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/01/2016.
//
//

#import "AppAlert.h"
#import "ofApparel.h"

@implementation AppAlert 

- (void) show
{
	UIAlertView *myAlert = [[UIAlertView alloc]
    	                        initWithTitle:@"Switch to Non-AR Mode"
        	                    message:@"No target has been detected. Try the app on a demo target at http://apparel.normalfutu.re or switch to non-AR mode."
            	                delegate:self
                	            cancelButtonTitle:@"Cancel"
                    	        otherButtonTitles:@"Switch", nil];

	[myAlert show];
    [myAlert release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

	if (buttonIndex == 0)
	{
        NSLog(@"user pressed Cancel");
    }
    else
	{
//        NSLog(@"user pressed Switch");

		ofApp* pApp = (ofApp*) ofGetAppPtr();
		if (pApp)
		{
			pApp->onAlertInfoSwitch();
		}
	}

}




@end
