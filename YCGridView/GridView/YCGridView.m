//
//  YCGridView.m
//  YCGridView
//
//  Created by YinChuan on 2018/11/15.
//  Copyright © 2018 YinChuan. All rights reserved.
//

#import "YCGridView.h"
#import "MJRefresh.h"

#define CELL_CONTENT_TAG 1000
#define CELL_CONTENT_FIRST_VIEW_TAG 100

@interface YCGridView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSArray * titles;

@property(nonatomic,strong)UIView * headerView;

@property(nonatomic,strong)NSMutableArray * dataSource;

@property(nonatomic)RefreshStyle refreshStyle;

@property(nonatomic,assign)BOOL isFirstLoad;
@end

@implementation YCGridView

///*******************************初始化的方法********************************
-(instancetype)initWithFrame:(CGRect)frame refreshStyle:(RefreshStyle)refreshStyle
{
    if(self == [super initWithFrame:frame])
    {
        _gridItemTextSize = 15;
        _gridItemTextColor = [UIColor redColor];
        _gridCellheight = 50;
        _isFirstLoad = YES;
        _dataSource = [[NSMutableArray alloc]init];
        _refreshStyle = refreshStyle?:RefreshStyleNone;
        _headerHeight = 50;
        _headerTitleSize = 15;
        _headerTitleColor = [UIColor blackColor];
    }
    return self;
}

-(void)setTitles:(NSArray*)titles headerHeight:(CGFloat)height
{
    _titles = titles;
    _headerHeight = height;
    ///创建header
    [self createHeaderViewWithTitles:titles height:height titleSize:_headerTitleSize titleColor:_headerTitleColor];
    ///创建表格
    [self createTableViewWithRefreshStyle:_refreshStyle];
}

///**************************************************************************

#pragma mark - 创建表格
-(void)createTableViewWithRefreshStyle:(RefreshStyle)refreshStyle
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = _gridCellheight;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_tableView];
    [self setRefreshWithStyle:refreshStyle];
}

#pragma mark - 设置MJRefresh刷新
-(void)setRefreshWithStyle:(RefreshStyle)refreshStyle
{
    if(!_tableView)
    {
        return;
    }
    MJRefreshBackNormalFooter * footerRefresh = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    MJRefreshNormalHeader * headerRefresh = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    headerRefresh.lastUpdatedTimeLabel.hidden = YES;
    headerRefresh.stateLabel.hidden = YES;
    
    switch (refreshStyle) {
        case RefreshStyleNone:
            break;
        case RefreshStyleAll:
            _tableView.mj_header = headerRefresh;
            _tableView.mj_footer = footerRefresh;
            break;
        case RefreshStyleFooter:
            _tableView.mj_footer = footerRefresh;
            break;
        case RefreshStyleHeader:
            _tableView.mj_header = headerRefresh;
            break;
        default:
            break;
    }
}

#pragma mark - 创建头部标题view
-(void)createHeaderViewWithTitles:(NSArray *)titles height:(CGFloat)height titleSize:(CGFloat)size titleColor:(UIColor*)color
{
    [[self.headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.headerView.frame = CGRectMake(0, 0, self.frame.size.width, height);
    CGFloat totalWeight = 0;
    for(int i=0;i<titles.count;i++)
    {
        NSDictionary * dict = [titles objectAtIndex:i];
        NSString * weight = [dict objectForKey:WEIGHT];
        totalWeight = totalWeight + weight.floatValue;
    }
    CGFloat W = 0;
    for(int i=0;i<titles.count;i++)
    {
        NSDictionary * dict = [titles objectAtIndex:i];
        NSString * title = [dict objectForKey:TITLE];
        NSString * weight = [dict objectForKey:WEIGHT];
        CGFloat width = self.frame.size.width/totalWeight*weight.floatValue;
        W = W + width;
        CGFloat X = W-width;
        CGRect frame = CGRectMake(X, 0, width, height);
        UILabel * titleLab = [self createLabelWithFrame:frame textSize:size textColor:color isLine:(i!=titles.count-1)];
        titleLab.text = title;
        [self.headerView addSubview:titleLab];
    }
}

#pragma mark - 创建UILabel
-(UILabel*)createLabelWithFrame:(CGRect)frame textSize:(NSInteger)size textColor:(UIColor*)color isLine:(BOOL)isLine
{
    UILabel * label = [[UILabel alloc]initWithFrame:frame];
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:size];
    label.numberOfLines = 0;
    if(isLine)
    {
        ///右边分割线
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(label.frame.size.width-lineSize, 0, lineSize, label.frame.size.height)];
        line.backgroundColor = [UIColor blackColor];
        [label addSubview:line];
    }
    return label;
}

#pragma mark - MJRefresh加载方法
-(void)loadMoreData
{
    if([_delegate respondsToSelector:@selector(gridViewFooterRefresh)])
    {
        [_delegate gridViewFooterRefresh];
    }
}

-(void)refreshData
{
    if([_delegate respondsToSelector:@selector(gridViewHeaderRefresh)])
    {
        [_delegate gridViewHeaderRefresh];
    }
}

#pragma mark - tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_isFirstLoad)
    {
        return 0;
    }
    return _dataSource.count>0?_dataSource.count:1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _headerHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isFirstLoad)
    {
        UITableViewCell * cell = [[UITableViewCell alloc]init];
        return cell;
    }
    if(_dataSource.count==0)
    {
        static NSString * EmtpyCellID = @"EmtpyCellID";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:EmtpyCellID];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EmtpyCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel * contentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, _headerHeight)];
            contentLab.font = [UIFont systemFontOfSize:18];
            contentLab.textAlignment = NSTextAlignmentCenter;
            contentLab.text = @"暂无数据";
            [cell.contentView addSubview:contentLab];
        }
        return cell;
    }
    static NSString * cellID = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:[self createItemView]];
    }
    
    NSDictionary * dataDict = [_dataSource objectAtIndex:indexPath.row];
    UIView * itemView = [cell.contentView viewWithTag:CELL_CONTENT_TAG];
    for(int i=0;i<_titles.count;i++)
    {
        NSDictionary * dict = [_titles objectAtIndex:i];
        NSString * key = [dict objectForKey:ARGS];
        id content = nil;
        if([key isEqualToString:PRIMARYKEY])
        {
            content = [NSString stringWithFormat:@"%ld",indexPath.row+1];
        }else
        {
            content = [dataDict objectForKey:key];
        }
        NSInteger tag = i+CELL_CONTENT_FIRST_VIEW_TAG;
        UILabel * view1 = (UILabel*)[itemView viewWithTag:tag];
        view1.text = [self getStringWithObj:content];
    }
    return cell;
}

#pragma mark - 懒加载
-(UIView *)headerView
{
    if(!_headerView)
    {
        _headerView = [[UIView alloc]init];
        _headerView.backgroundColor = [UIColor whiteColor];
        _headerView.layer.borderColor = [UIColor blackColor].CGColor;
        _headerView.layer.borderWidth = lineSize;
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

-(UIView*)createItemView
{
    UIView * itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, _gridCellheight)];
    itemView.tag = CELL_CONTENT_TAG;
    itemView.backgroundColor = [UIColor whiteColor];
    UIView * bootmLine = [[UIView alloc]initWithFrame:CGRectMake(0, itemView.frame.size.height-lineSize, itemView.frame.size.width, lineSize)];
    bootmLine.backgroundColor = [UIColor blackColor];
    [itemView addSubview:bootmLine];
    
    UIView * leftLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, lineSize, itemView.frame.size.height)];
    leftLine.backgroundColor = [UIColor blackColor];
    [itemView addSubview:leftLine];
    
    CGFloat totalWeight = 0;
    for(int i=0;i<_titles.count;i++)
    {
        NSDictionary * dict = [_titles objectAtIndex:i];
        NSString * weight = [dict objectForKey:WEIGHT];
        totalWeight = totalWeight + weight.floatValue;
    }
    
    CGFloat W = 0;
    for(int i=0;i<_titles.count;i++)
    {
        NSDictionary * dict = [_titles objectAtIndex:i];
        NSString * weight = [dict objectForKey:WEIGHT];
        CGFloat width = self.frame.size.width/totalWeight*weight.floatValue;
        W = W + width;
        CGFloat X = W-width;
        CGRect frame = CGRectMake(X, 0, width, itemView.frame.size.height);
        UILabel * contentLab = [self createLabelWithFrame:frame textSize:_gridItemTextSize textColor:_gridItemTextColor isLine:YES];
        contentLab.tag = CELL_CONTENT_FIRST_VIEW_TAG+i;
        [itemView addSubview:contentLab];
    }
    return itemView;
}

///*****************************************
-(void)setHeaderTitleWithTextSize:(CGFloat)size textColor:(UIColor*)color
{
    if(!_titles || _titles.count==0)
    {
        return;
    }
    _headerTitleColor = color;
    _headerTitleSize = size;
    [self createHeaderViewWithTitles:_titles height:_headerHeight titleSize:size titleColor:color];
}

- (void)setHeaderViewTitleSize:(CGFloat)headerViewTitleSize
{
    [self setHeaderTitleWithTextSize:headerViewTitleSize textColor:_headerTitleColor];
}

-(void)setHeaderViewTitleColor:(UIColor *)headerViewTitleColor
{
    [self setHeaderTitleWithTextSize:_headerTitleSize textColor:headerViewTitleColor];
}

-(void)setHeaderViewbackgroundColor:(UIColor *)headerViewbackgroundColor
{
    self.headerView.backgroundColor = headerViewbackgroundColor;
}

///******************************************
-(void)setDataWithArr:(NSArray*)arr
{
    [_dataSource removeAllObjects];
    _dataSource = [NSMutableArray arrayWithArray:arr];
    if(_tableView)
    {
        _isFirstLoad = NO;
        [_tableView reloadData];
        [self endRefreshing];
    }
}

#pragma mark - 数据源，同时是否还有更多数据
-(void)setDataWithArr:(NSArray*)arr isNoMoreData:(BOOL)status
{
    [_dataSource removeAllObjects];
    _dataSource = [NSMutableArray arrayWithArray:arr];
    if(_tableView)
    {
        _isFirstLoad = NO;
        [_tableView reloadData];
        if(status)
        {
            [self endRefreshingWithNoMoreData];
        }else
        {
            [self endRefreshing];
        }
    }
}

#pragma mark - 结束刷新
-(void)endHeaderRefresh
{
    if(!_tableView)
    {
        return;
    }
    if((_refreshStyle==RefreshStyleHeader || _refreshStyle==RefreshStyleAll) && [_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
    }
}

-(void)endFooterRefresh
{
    if(!_tableView)
    {
        return;
    }
    if([_tableView.mj_footer isRefreshing] && (_refreshStyle==RefreshStyleAll || _refreshStyle==RefreshStyleFooter))
    {
        [_tableView.mj_footer endRefreshing];
    }
}

-(void)endRefreshing
{
    if(!_tableView || _refreshStyle==RefreshStyleNone)
    {
        return;
    }
    if((_refreshStyle==RefreshStyleHeader || _refreshStyle==RefreshStyleAll) && [_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        if((_refreshStyle==RefreshStyleAll || _refreshStyle==RefreshStyleFooter))
        {
            [_tableView.mj_footer endRefreshing];
        }
    }
    
    if([_tableView.mj_footer isRefreshing] && (_refreshStyle==RefreshStyleAll || _refreshStyle==RefreshStyleFooter))
    {
        [_tableView.mj_footer endRefreshing];
    }
    
    if(_dataSource.count==0 && (_refreshStyle==RefreshStyleAll || _refreshStyle==RefreshStyleFooter))
    {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

-(void)endRefreshingWithNoMoreData
{
    if(!_tableView)
    {
        return;
    }
    if(_refreshStyle==RefreshStyleAll || _refreshStyle==RefreshStyleFooter)
    {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

///****************************
-(NSString*)getStringWithObj:(id)obj
{
    if(!obj)
    {
        return @"";
    }
    if([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    if([obj isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",obj];
    }
    return @"";
}

///********************
-(void)beginRefreshing
{
    [_tableView.mj_header beginRefreshing];
}

@end
