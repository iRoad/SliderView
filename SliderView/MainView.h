//
//  MainView.h
//  Weather
//
//  Created by 李建平 on 16/6/27.
//  Copyright © 2016年 Wxl.Haiyue. All rights reserved.
//

typedef enum state {
    kStateHome, // 主页
    kStateMenu, // 设置页
}state;

#import <UIKit/UIKit.h>
#import "WRBackgroundView.h"

@interface MainView : UIView

/// 背景层
@property (nonatomic, strong) WRBackgroundView *backgroundView;

/// 最小化，菜单距离左边大小
@property (nonatomic, assign) CGFloat leftDistance;
/// 最小化，菜单的宽度，即距离右边距离
@property (nonatomic, assign) CGFloat rightDistance;
/// 最小化，主视图的最小x
@property (nonatomic, assign) CGFloat minX;

/// 主视图控制器
@property (nonatomic, weak) UIViewController *homeViewController;
/// 菜单视图控制器
@property (nonatomic, weak) UIViewController *menuViewController;

/// 主视图的容器 主要进行动画
@property (nonatomic, strong, readonly) UIView *homeView;
/// 菜单视图的容器 主要进行动画
@property (nonatomic, strong, readonly) UIView *menuView;

/// 主视图滑动时的遮罩
@property (nonatomic, strong, readonly) UIView *shadowView;

/// 滑动手势
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *handlePan;
/// 点击手势
@property (nonatomic, strong, readonly) UITapGestureRecognizer *handleTap;

/// 当前状态
@property (nonatomic, assign) state sta;

+ (instancetype)view;

/** 添加主视图 */
- (void)addHomeViewWithController:(UIViewController *)viewController;
/** 添加菜单视图 */
- (void)addMenuViewWithController:(UIViewController *)viewController;

/** 展示菜单视图 */
- (void)showMenuWithAnimated:(BOOL)animated;
/** 展示主视图 */
- (void)showHomeWithAnimated:(BOOL)animated;

/** 添加背景层的方法 如果需要添加到不同的层 可以重写 */
- (void)setupBackgroundView;
/** 背景图片改变的回调方法 */
- (void)backgroundImageChanged;

- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewDidDisAppear;
- (void)viewWillDisAppear;

@end
