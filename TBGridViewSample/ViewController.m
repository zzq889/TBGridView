//
//  ViewController.m
//  TBGridViewSample
//
//  Created by Zhang Zeqing on 11/9/12.
//  Copyright (c) 2012 Zhang Zeqing. All rights reserved.
//

#import "ViewController.h"
#import "TaskboardViewCell.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize gridView = _gridView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    
    TBGridView *gridView = [[TBGridView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height - 40)];
    [gridView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    gridView.gridViewDataSource = self;
    gridView.gridViewDelegate = self;
    self.gridView = gridView;
    [self.view addSubview:self.gridView];
    
    [self.gridView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTBGridView:(TBGridView *)gridView
{
    return 3;
}

- (NSInteger)numberOfRowsInTBGridView:(TBGridView *)gridView forSection:(NSInteger)section
{
    return 10;
}

- (TBGridViewCell *)gridView:(TBGridView *)gridView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskboardViewCell *cell = (TaskboardViewCell *)[gridView dequeueReusableCell];
    if (!cell) {
        cell = [[TaskboardViewCell alloc] initWithFrame:CGRectZero];
    }
    [cell fillViewWithObject:[NSString stringWithFormat:@"Idx %d, %d", indexPath.section, indexPath.row]];
    
    return cell;
}

#pragma mark - gridview delegate
- (void)gridView:(TBGridView *)gridView didSelectCell:(TBGridViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath: %@", indexPath);
}


@end
