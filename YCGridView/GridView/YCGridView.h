//
//  YCGridView.h
//  YCGridView
//
//  Created by YiXian_YinChuan on 2018/11/15.
//  Copyright © 2018 YiXian_YinChuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define lineSize 0.5

#define TITLE @"title"
#define WEIGHT @"weight"
#define ARGS @"args"
#define PRIMARYKEY @"primaryKey"

///刷新风格
typedef enum
{
    RefreshStyleNone,///不要刷新
    RefreshStyleHeader,///下拉刷新
    RefreshStyleFooter,///上拉刷新
    RefreshStyleAll///上拉和下拉
}RefreshStyle;

@protocol YCGridViewDelegate<NSObject>
@optional
-(void)gridViewHeaderRefresh;

-(void)gridViewFooterRefresh;
@end

@interface YCGridView : UIView

@property(nonatomic)id<YCGridViewDelegate> delegate;

@property(nonatomic,assign)CGFloat gridCellheight; ///cell高度
@property(nonatomic,assign)CGFloat gridItemTextSize;///cell文字大小
@property(nonatomic,strong)UIColor * gridItemTextColor;///cell文字颜色

@property(nonatomic,assign)CGFloat headerHeight;///头部高度
@property(nonatomic,strong)UIColor * headerTitleColor;///头部标题颜色
@property(nonatomic,assign)CGFloat headerTitleSize;///头部标题大小
@property(nonatomic,strong)UIColor * headerBackgroundColor;///头部背景颜色

-(instancetype)initWithFrame:(CGRect)frame refreshStyle:(RefreshStyle)refreshStyle;
///创建头部标题View
-(void)setTitles:(NSArray*)titles headerHeight:(CGFloat)height;

-(void)setRefreshWithStyle:(RefreshStyle)refreshStyle;

///设置头部标题字体样式
-(void)setHeaderTitleWithTextSize:(CGFloat)size textColor:(UIColor*)color;


-(void)setDataWithArr:(NSArray*)arr;
-(void)setDataWithArr:(NSArray*)arr isNoMoreData:(BOOL)status;

-(void)endHeaderRefresh;
-(void)endFooterRefresh;
-(void)endRefreshing;
-(void)endRefreshingWithNoMoreData;
-(void)beginRefreshing;

@end
