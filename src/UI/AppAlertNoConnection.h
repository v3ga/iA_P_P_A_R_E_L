//
//  AppAlertNoConnection.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 18/01/2016.
//
//

#import <Foundation/Foundation.h>

@interface AppAlertNoConnection : NSObject <UIAlertViewDelegate>

- (void) show;
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@end


