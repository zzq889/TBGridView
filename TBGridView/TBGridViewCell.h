//
//  TBGridViewCell.h
//  TBGridViewSample
//
//  Created by Zhang Zeqing on 27/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBGridViewCell : UIView

@property (nonatomic, retain) id object;

- (void)prepareForReuse;
- (void)fillViewWithObject:(id)object;
+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth;

@end
