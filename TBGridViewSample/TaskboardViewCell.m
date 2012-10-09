//
//  TaskboardViewCell.m
//  TBGridViewSample
//
//  Created by Zhang Zeqing on 28/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//
#define MARGIN 20.0

#import "TaskboardViewCell.h"

@interface TaskboardViewCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *captionLabel;

@end

@implementation TaskboardViewCell

@synthesize
bgView = _bgView,
captionLabel = _captionLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.captionLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.captionLabel.numberOfLines = 0;
        self.captionLabel.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.captionLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.captionLabel.text = nil;
}

- (void)dealloc {
    self.bgView = nil;
    self.captionLabel = nil;
}

- (void)fillViewWithObject:(id)object {
    [super fillViewWithObject:object];
    self.captionLabel.text = object;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
    
    // bgView
    self.bgView.frame = CGRectMake(left, 0, width, self.frame.size.height - MARGIN);
    
    // Label
    CGSize labelSize = CGSizeZero;
    labelSize = [self.captionLabel.text sizeWithFont:self.captionLabel.font constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:self.captionLabel.lineBreakMode];
    top = MARGIN;
    
    self.captionLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

@end
