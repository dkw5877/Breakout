//
//  BlockView.m
//  Breakout
//
//  Created by user on 3/20/14.
//  Copyright (c) 2014 Marion Ano. All rights reserved.
//

#import "BlockView.h"

@implementation BlockView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.hits = arc4random()%2;
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
