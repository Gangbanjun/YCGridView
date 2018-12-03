//
//  ViewController.m
//  YCGridView
//
//  Created by YiXian_YinChuan on 2018/11/15.
//  Copyright © 2018 YiXian_YinChuan. All rights reserved.
//

#import "ViewController.h"
#import "YCGridView.h"
@interface ViewController ()<YCGridViewDelegate>
@property(nonatomic,strong)YCGridView * gridView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    _gridView = [[YCGridView alloc]initWithFrame:CGRectMake(10, 60, self.view.frame.size.width-20, self.view.frame.size.height-100) refreshStyle:RefreshStyleHeader];
    _gridView.delegate = self;
    _gridView.gridItemTextColor = [UIColor yellowColor];
    _gridView.gridItemTextSize = 20;
    _gridView.gridCellheight = 50;
    NSArray * titles = @[
                         @{TITLE:@"1",@"weight":@"3",@"args":@"c1"},
                         @{TITLE:@"2",@"weight":@"2",@"args":@"c2"}
                         ];
    [_gridView setTitles:titles headerHeight:40];
    _gridView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_gridView];
}

-(void)gridViewHeaderRefresh
{
    NSArray * arr = @[@{@"c1":@"2",
                        @"c2":@"3"},
                      @{@"c1":@"3",
                        @"c2":@"4"},
                      @{@"c1":@"5",
                        @"c2":@"6"},
                      @{@"c1":@"7",
                        @"c2":@"8"},
                      @{@"c1":@"9",
                        @"c2":@"10"},
                      @{@"c1":@"11",
                        @"c2":@"12"},
                      @{@"c1":@"13",
                        @"c2":@"14"},
                      ];
    [_gridView setDataWithArr:arr];
    [_gridView endRefreshing];
}

@end
