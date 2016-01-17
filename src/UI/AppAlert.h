//
//  AppAlert.h
//  iA_P_P_A_R_E_L
//
//  Created by Julien on 17/01/2016.
//
//
// useful : http://forum.macbidouille.com/index.php?showtopic=320413

#import <Foundation/Foundation.h>

@interface AppAlert : NSObject <UIAlertViewDelegate>

- (void) show;
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
