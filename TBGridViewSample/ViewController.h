//
//  ViewController.h
//  TBGridViewSample
//
//  Created by Zhang Zeqing on 11/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBGridView.h"

@interface ViewController : UIViewController <TBGridViewDelegate, TBGridViewDataSource>

@property (nonatomic, strong) TBGridView *gridView;

@end
