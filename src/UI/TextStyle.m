//
//  TextStyle.m
//  Apparel 1.0
//
//  Created by Aurélien Michon on 15/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//

#import "TextStyle.h"

@interface TextStyle ()

@end

@implementation TextStyle

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:@"LetterGothicStd-Bold" size:13];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
