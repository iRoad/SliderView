//
//  MainView.m
//  Weather
//
//  Created by 李建平 on 16/6/27.
//  Copyright © 2016年 Wxl.Haiyue. All rights reserved.
//

#import "MainView.h"
#import "WeatherBackgroundManager.h"
#import "iPadMainView.h"
#import "iPhoneMainView.h"

@interface MainView()

@property (nonatomic, strong, readwrite) UIView *shadowView;

@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *handlePan;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *handleTap;

/// 主视图的容器 主要进行动画
@property (nonatomic, strong, readwrite) UIView *homeView;
/// 菜单视图的容器 主要进行动画
@property (nonatomic, strong, readwrite) UIView *menuView;

@end

@implementation MainView

+ (instancetype)view {
    if ([UIDevice currentDevice].isPad) {
        return [[iPadMainView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    } else {
        return [[iPhoneMainView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
 
        self.sta = kStateHome;
        
        // 添加手势 点击
        self.handleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.handleTap.enabled = NO;
        [self addGestureRecognizer:self.handleTap];
        
        // 添加手势 滑动
        self.handlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.handlePan.enabled = NO;
        [self addGestureRecognizer:self.handlePan];
        
        __weak typeof(self) weakSelf = self;
        self.backgroundView.imgChanged = ^{
            [weakSelf backgroundImageChanged];
        };
    }
    return self;
}

- (UIView *)homeView {
    if (!_homeView) {
        _homeView = [[UIView alloc] initWithFrame:self.bounds];
        _homeView.backgroundColor = [UIColor clearColor];
        [self addSubview:_homeView];
    }
    return _homeView;
}

- (UIView *)menuView {
    if (!_menuView) {
        _menuView = [[UIView alloc] initWithFrame:self.bounds];
        _menuView.backgroundColor = [UIColor clearColor];
        _menuView.hidden = YES;
        [self insertSubview:_menuView belowSubview:self.homeView];
    }
    return _menuView;
}

- (void)addHomeViewWithController:(UIViewController *)viewController {
    self.homeViewController = viewController;
    
    viewController.view.frame = self.homeView.bounds;
    [self.homeView addSubview:viewController.view];
    
    // 背景的添加 iphone和ipad处理不同
    [self setupBackgroundView];
}

- (void)addMenuViewWithController:(UIViewController *)viewController {
    self.menuViewController = viewController;
    
    // iphone ipad 处理不同 在子类重写
}

- (void)setupBackgroundView {
    [self.backgroundView addToController:self.currentViewController];
    
    // home view 遮罩
    self.shadowView = [[UIImageView alloc] initWithFrame:self.homeView.bounds];
    self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    self.shadowView.hidden = YES;
    self.shadowView.alpha = 0.0;
    [self.backgroundView addSubview:self.shadowView];
}

#pragma mark - Background image
- (void)backgroundImageChanged {
}

#pragma mark - Getter
- (WRBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [WRBackgroundView sharedBackgroundView];
    }
    return _backgroundView;
}

#pragma mark - Action
- (void)handlePan:(UIPanGestureRecognizer *)sender {
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [self showHomeWithAnimated:YES];
}

#pragma mark -
- (void)showMenuWithAnimated:(BOOL)animated {
}

- (void)showHomeWithAnimated:(BOOL)animated {
}

- (void)viewWillAppear {
}
- (void)viewDidAppear {
    [self.backgroundView startCCAnimation];
}
- (void)viewDidDisAppear {
}
- (void)viewWillDisAppear {
    [self.backgroundView stopCCAnimation];
}

@end
