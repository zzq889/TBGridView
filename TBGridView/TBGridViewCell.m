//
//  TBGridViewCell.m
//  TBGridViewSample
//
//  Created by Zhang Zeqing on 27/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//

#import "TBGridViewCell.h"

@interface TBGridViewCell ()

@end

@implementation TBGridViewCell

@synthesize
object = _object;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
}

- (void)prepareForReuse {
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    return 0.0;
}

@end
