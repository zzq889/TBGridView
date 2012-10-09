//
//  TBShelfScrollView.h
//  TBShelfScrollViewControllerSample
//
//  Created by Zhang Zeqing on 5/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBGridViewCell;

@protocol TBGridViewDelegate, TBGridViewDataSource;

@interface TBGridView : UIView <UIScrollViewDelegate>

#pragma mark - Public Properties
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) id <TBGridViewDelegate> gridViewDelegate;
@property (nonatomic, assign) id <TBGridViewDataSource> gridViewDataSource;

#pragma mark - Public Methods
- (void)reloadData;
- (TBGridViewCell *)dequeueReusableCell;

@end

#pragma mark - Delegate

@protocol TBGridViewDelegate <NSObject>

@optional
- (void)gridView:(TBGridView *)gridView didSelectCell:(TBGridViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - DataSource

@protocol TBGridViewDataSource <NSObject>

@required
- (NSInteger)numberOfSectionsInTBGridView:(TBGridView *)gridView;
- (NSInteger)numberOfRowsInTBGridView:(TBGridView *)gridView forSection:(NSInteger)section;
- (TBGridViewCell *)gridView:(TBGridView *)gridView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end