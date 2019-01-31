//
//  iPhoneMainView.m
//  Weather
//
//  Created by 李建平 on 2018/1/23.
//  Copyright © 2018年 Appfactory. All rights reserved.
//

#import "iPhoneMainView.h"
#import "WRWallpaperView.h"

static const CGFloat viewHeightNarrowRatio = 0.80;
static const CGFloat menuStartNarrowRatio  = 0.70;

@interface iPhoneMainView ()

@property (nonatomic, strong) WRWallpaperView *menuBackgroundImgView;

@end

@implementation iPhoneMainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftDistance = 65.0;
        self.rightDistance = self.frame.size.width-self.leftDistance;
        
        // 菜单背景
        self.menuBackgroundImgView = [[WRWallpaperView alloc] initWithFrame:self.bounds];
        self.menuBackgroundImgView.blackAlpha = 0.7;
        self.menuBackgroundImgView.hidden = YES;
        [self addSubview:self.menuBackgroundImgView];
    }
    return self;
}

- (void)addMenuViewWithController:(UIViewController *)viewController {
    [super addMenuViewWithController:viewController];
    
    // 需要展示的尺寸
    CGFloat menuX = self.leftDistance;
    CGFloat menuY = CGRectGetHeight(self.frame)*((1-viewHeightNarrowRatio)/2.0);
    CGFloat menuW = CGRectGetWidth(self.frame)-menuX;
    CGFloat menuH = CGRectGetHeight(self.frame)-menuY;
    
    // 添加视图 默认的方法
    self.menuView.frame = CGRectMake(menuX, menuY, menuW, menuH);
    viewController.view.frame = self.menuView.bounds;
    [self.menuView addSubview:viewController.view];
    
    // 初始状态 iphone 需要首先缩放
    self.menuView.transform = CGAffineTransformScale(CGAffineTransformIdentity, menuStartNarrowRatio, menuStartNarrowRatio);
}

- (void)setupBackgroundView {
    [self.backgroundView addToController:self.homeViewController];
}

#pragma mark - Background image
- (void)backgroundImageChanged {
    if (!self.menuBackgroundImgView.hidden) {
        self.menuBackgroundImgView.image = [WeatherBackgroundManager sharedManager].bgimg;
    }
}

#pragma mark - Action
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (self.sta != kStateMenu) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        // 水平拖拽
        CGPoint translation = [sender translationInView:self];
        CGFloat x = translation.x;
        if (self.homeView.frame.origin.x+x<=self.minX) {
            return;
        } else if (self.homeView.frame.origin.x+x>0) {
            return;
        }
        
        // 偏移量
        self.homeView.transform = CGAffineTransformTranslate(self.homeView.transform, x, 0);
        
        // 缩放
        CGFloat homeScale = 1+((1-viewHeightNarrowRatio)/self.rightDistance)*x;
        self.homeView.transform = CGAffineTransformScale(self.homeView.transform, homeScale, homeScale);
        
        // 对rightView进行缩放
        CGFloat menuScale = 1-((1-menuStartNarrowRatio)/self.rightDistance)*x;
        self.menuView.transform = CGAffineTransformScale(self.menuView.transform, menuScale, menuScale);
        
        // 识别器的位移复位
        [sender setTranslation:CGPointZero inView:self];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (CGRectGetMaxX(self.homeView.frame)>=self.center.x) {
            [self showHomeWithAnimated:YES];
        } else {
            [self showMenuWithAnimated:YES];
        }
    }
}

#pragma mark - 展示相关
- (void)showMenuWithAnimated:(BOOL)animated {
    self.handlePan.enabled = YES;
    self.handleTap.enabled = YES;
    self.menuBackgroundImgView.hidden = NO;
    self.menuView.hidden = NO;
    self.homeView.userInteractionEnabled = NO;
    self.shadowView.hidden = NO;
    
    CGFloat scale = viewHeightNarrowRatio;
    CGFloat endX = -(self.frame.size.width-self.leftDistance);
    CGFloat moveX = (endX+(self.frame.size.width*(1-scale))/2)/scale;
    
    if (animated) {
        // 忽略所有的touch事件
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            
            CGAffineTransform tranform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
            
            tranform = CGAffineTransformTranslate(tranform, moveX, 0);
            
            weakSelf.homeView.transform = tranform;
            weakSelf.menuView.transform = CGAffineTransformIdentity;
            weakSelf.menuView.alpha = 1.0;
            weakSelf.shadowView.alpha = 1.0;
            weakSelf.minX = weakSelf.homeView.frame.origin.x;
        } completion:^(BOOL finished) {
            weakSelf.sta = kStateMenu;
            // 开始接受所有的touch事件
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else {
        CGAffineTransform tranform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        tranform = CGAffineTransformTranslate(tranform, moveX, 0);
        
        self.homeView.transform = tranform;
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.alpha = 1.0;
        self.shadowView.alpha = 1.0;
        self.minX = self.homeView.frame.origin.x;
        
        self.sta = kStateMenu;
    }
    
    // 更新背景
    [self backgroundImageChanged];
}

- (void)showHomeWithAnimated:(BOOL)animated {
    if (animated) {
        // 忽略所有的touch事件
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        __block CGFloat scale = menuStartNarrowRatio;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.homeView.transform = CGAffineTransformIdentity;
            weakSelf.menuView.transform = CGAffineTransformScale(weakSelf.menuView.transform, scale, scale);
            weakSelf.menuView.alpha = 0.0;
            weakSelf.shadowView.alpha = 0.0;
        } completion:^(BOOL finished) {
            weakSelf.menuView.hidden = YES;
            weakSelf.menuBackgroundImgView.hidden = YES;
            weakSelf.homeView.userInteractionEnabled = YES;
            weakSelf.shadowView.hidden = YES;
            weakSelf.sta = kStateHome;
            weakSelf.handlePan.enabled = NO;
            weakSelf.handleTap.enabled = NO;
            
            // 开始接受所有的touch事件
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else {
        CGFloat scale = menuStartNarrowRatio;
        
        self.homeView.transform = CGAffineTransformIdentity;
        self.menuView.transform = CGAffineTransformScale(self.menuView.transform, scale, scale);
        self.menuView.alpha = 0.0;
        self.shadowView.alpha = 0.0;
        
        self.menuView.hidden = YES;
        self.menuBackgroundImgView.hidden = YES;
        self.homeView.userInteractionEnabled = YES;
        self.shadowView.hidden = YES;
        self.sta = kStateHome;
        self.handlePan.enabled = NO;
        self.handleTap.enabled = NO;
    }
}

@end
