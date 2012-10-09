//
//  TBShelfScrollView.m
//  TBShelfScrollViewControllerSample
//
//  Created by Zhang Zeqing on 5/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//

#import "TBGridView.h"
#import "TBGridViewCell.h"

#pragma mark - Gesture Recognizer

@interface TBGridViewTapGestureRecognizer : UITapGestureRecognizer
@end

@implementation TBGridViewTapGestureRecognizer
@end


@interface TBGridViewLongPressGestureRecognizer : UILongPressGestureRecognizer
@end

@implementation TBGridViewLongPressGestureRecognizer
@end


@interface TBGridViewPanGestureRecognizer : UIPanGestureRecognizer
@end

@implementation TBGridViewPanGestureRecognizer
@end


@interface TBGridView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat showsWidth;
@property (nonatomic, strong) NSMutableArray *sectionColumns;
@property (nonatomic, strong) NSMutableSet *reuseableCells;
@property (nonatomic, strong) NSMutableDictionary *visibleCells;
@property (nonatomic, strong) NSMutableArray *viewKeysToRemove;

- (void)relayoutViews;
- (void)enqueueReusableCell:(TBGridViewCell *)cell;
- (void)removeAndAddCellsIfNecessary;

@end

@implementation TBGridView

// Public
@synthesize
rowHeight = _rowHeight,
gridViewDelegate = _gridViewDelegate,
gridViewDataSource = _gridViewDataSource;

// Private
@synthesize
topMargin = _topMargin,
showsWidth = _showsWidth,
scrollView = _scrollView,
sectionColumns = _sectionColumns,
orientation = _orientation,
reuseableCells = _reuseableCells,
visibleCells = _visibleCells,
viewKeysToRemove = _viewKeysToRemove;

#pragma mark - Init/Memory
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.topMargin = 50.0f;
        self.showsWidth = 40.0f;
        self.rowHeight = 200.0f;
        self.clipsToBounds = YES;
        
        self.orientation = [UIApplication sharedApplication].statusBarOrientation;
        self.reuseableCells = [NSMutableSet set];
        self.visibleCells = [NSMutableDictionary dictionary];
        self.viewKeysToRemove = [NSMutableArray array];
        self.sectionColumns = [NSMutableArray array];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_showsWidth, 0, self.bounds.size.width - _showsWidth * 2, self.bounds.size.height)];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        scrollView.delegate = self;
        scrollView.clipsToBounds = NO;
        scrollView.pagingEnabled = YES;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        self.scrollView = scrollView;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)dealloc {
    // clear delegates
    self.gridViewDelegate = nil;
    self.gridViewDataSource = nil;
    
    self.scrollView = nil;
    self.reuseableCells = nil;
    self.visibleCells = nil;
    self.viewKeysToRemove = nil;
    self.sectionColumns = nil;
}

#pragma mark - Setters

#pragma mark - DataSource

- (void)reloadData {
    [self relayoutViews];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.frame.size.height);
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.orientation != orientation) {
        self.orientation = orientation;
        [self relayoutViews];
    } else {
        [self removeAndAddCellsIfNecessary];
    }
}

- (void)relayoutViews
{
    // Reset all state
    [self.visibleCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        TBGridViewCell *cell = (TBGridViewCell *)obj;
        [self enqueueReusableCell:cell];
    }];
    [self.visibleCells removeAllObjects];
    [self.viewKeysToRemove removeAllObjects];
    [self.sectionColumns removeAllObjects];
//    [self.indexToRectMap removeAllObjects];
    
    // This is where we should layout the entire grid first
    if (self.scrollView.subviews.count) {
        [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *view = (UIView *)obj;
            [view removeFromSuperview];
        }];
    }
    
    NSInteger numCols = [self.gridViewDataSource numberOfSectionsInTBGridView:self];
    CGRect columnFrame = CGRectMake(0, 0, self.scrollView.bounds.size.width, _rowHeight);
    NSInteger colIdx = 0;
    while (colIdx < numCols) {
        UIScrollView *scrollView = [UIScrollView new];
        scrollView.frame = columnFrame;
        scrollView.scrollsToTop = NO;
        scrollView.clipsToBounds = NO;
        scrollView.pagingEnabled = YES;
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        scrollView.alwaysBounceVertical = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        columnFrame.origin.x += self.scrollView.bounds.size.width;
        NSInteger numRows = [self.gridViewDataSource numberOfRowsInTBGridView:self forSection:colIdx];
        scrollView.contentSize = CGSizeMake(columnFrame.size.width, _rowHeight * numRows);
        
        [self.scrollView addSubview:scrollView];
        [self.sectionColumns addObject:scrollView];
        colIdx++;
    }
    
    self.scrollView.contentSize = CGSizeMake(columnFrame.origin.x, self.frame.size.height);
    [self removeAndAddCellsIfNecessary];
}

- (void)removeAndAddCellsIfNecessary
{
    NSInteger numColumns = [self.gridViewDataSource numberOfSectionsInTBGridView:self];
    if (numColumns == 0) return;
    
    // TODO
    NSInteger currentSection = (self.scrollView.contentOffset.x + _showsWidth)  / self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width / 2) / self.scrollView.frame.size.width) + 1;
    [self.sectionColumns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIScrollView *scrollView = (UIScrollView *)obj;
        scrollView.scrollsToTop = (idx == page);
    }];
    
    // Remove all rows that are not inside the visible rect
    [self.visibleCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSIndexPath *indexPath = (NSIndexPath *)key;
        TBGridViewCell *cell = (TBGridViewCell *)obj;
        CGRect viewRect = cell.frame;
        if (
            (currentSection && indexPath.section == currentSection - 1)
            || (currentSection < numColumns - 1 && indexPath.section == currentSection + 1)
            || (currentSection == indexPath.section)
            ) {
            // Find out what rows are visible
            UIScrollView *scrollView = [self.sectionColumns objectAtIndex:indexPath.section];
            CGRect visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height);
            
            if (!CGRectIntersectsRect(visibleRect, viewRect)) {
                [self enqueueReusableCell:cell];
                [self.viewKeysToRemove addObject:key];
            }
            
        } else {
            [self enqueueReusableCell:cell];
            [self.viewKeysToRemove addObject:key];
        }
    }];
    
    [self.visibleCells removeObjectsForKeys:self.viewKeysToRemove];
    [self.viewKeysToRemove removeAllObjects];
    
    // If view is within visible rect and is not already shown
    for (NSInteger sec = MAX(0, currentSection - 1); sec < MIN(numColumns, currentSection + 2); sec++) {
        UIScrollView *scrollView = [self.sectionColumns objectAtIndex:sec];
        NSInteger numRows = [self.gridViewDataSource numberOfRowsInTBGridView:self forSection:sec];
        NSInteger topRow = (scrollView.contentOffset.y - _topMargin) / _rowHeight;
        NSInteger bottomRow = MIN((scrollView.contentOffset.y + _scrollView.frame.size.height - _topMargin) / _rowHeight + 1, numRows);
        NSInteger currentRow = topRow;
        while (currentRow < bottomRow) {
            NSIndexPath *key = [NSIndexPath indexPathForRow:currentRow inSection:sec];
            if (![self.visibleCells objectForKey:key]) {
                TBGridViewCell *newCell = [self.gridViewDataSource gridView:self cellForRowAtIndexPath:key];
                newCell.frame = CGRectMake(0, _topMargin + key.row * _rowHeight, scrollView.frame.size.width, _rowHeight);
                [scrollView addSubview:newCell];
                
                // Setup gesture recognizer
                if ([newCell.gestureRecognizers count] == 0) {
                    
                    TBGridViewTapGestureRecognizer *tapGestureRecognizer = [[TBGridViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectView:)];
                    tapGestureRecognizer.delegate = self;
                    [newCell addGestureRecognizer:tapGestureRecognizer];
                    
                    newCell.userInteractionEnabled = YES;
                }
                
                [self.visibleCells setObject:newCell forKey:key];
            }
            currentRow++;
        }
    }
    
    
}

#pragma mark - Reusing Views

- (TBGridViewCell *)dequeueReusableCell
{
    TBGridViewCell *cell = [self.reuseableCells anyObject];
    if (cell) {
        // Found a reusable view, remove it from the set
        [self.reuseableCells removeObject:cell];
    }
    
    return cell;
}

- (void)enqueueReusableCell:(TBGridViewCell *)cell
{
    if ([cell respondsToSelector:@selector(prepareForReuse)]) {
        [cell performSelector:@selector(prepareForReuse)];
    }
    cell.frame = CGRectZero;
    [self.reuseableCells addObject:cell];
    [cell removeFromSuperview];
}

#pragma mark UIView methods

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if ((point.x > self.bounds.size.width - _showsWidth || point.x < _showsWidth) && [self pointInside:point withEvent:event]) {
		return _scrollView;
	} else {
        // select cell
        NSInteger currentSection = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
        UIScrollView *scrollView = [self.sectionColumns objectAtIndex:currentSection];
        for (UIView *view in [scrollView subviews]) {
            if (CGRectContainsPoint(view.frame, CGPointMake(point.x - self.scrollView.frame.origin.x, point.y + scrollView.contentOffset.y))) {
                return view;
            }
        }
        return scrollView;
    }
	return [super hitTest:point withEvent:event];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self removeAndAddCellsIfNecessary];
}

#pragma mark - Gesture Recognizer

- (void)didSelectView:(UITapGestureRecognizer *)gestureRecognizer {
    NSInteger currentSection = (self.scrollView.contentOffset.x + _showsWidth)  / self.scrollView.frame.size.width;
    NSInteger currentRow = (gestureRecognizer.view.frame.origin.y - _topMargin) / _rowHeight;
    NSIndexPath *key = [NSIndexPath indexPathForRow:currentRow inSection:currentSection];
    if ([gestureRecognizer.view isMemberOfClass:[[self.visibleCells objectForKey:key] class]]) {
        if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectCell:atIndexPath:)]) {
            [self.gridViewDelegate gridView:self didSelectCell:(TBGridViewCell *)gestureRecognizer.view atIndexPath:key];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)theGestureRecognizer {
    
    return YES;
}

@end