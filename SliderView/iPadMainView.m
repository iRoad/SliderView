//
//  iPadMainView.m
//  Weather
//
//  Created by 李建平 on 2018/1/23.
//  Copyright © 2018年 Appfactory. All rights reserved.
//

#import "iPadMainView.h"

static const CGFloat iPad_MenuWidth  = 400.0;

@implementation iPadMainView

- (instancetype)initWithFrame:(CGRect)frame
{
    // 修复初始化时，frame在iOS7上异常问题
    if (frame.size.width<frame.size.height) {
        CGFloat temp = frame.size.height;
        frame.size.height = frame.size.width;
        frame.size.width = temp;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.rightDistance = 400.0;
        self.leftDistance = self.frame.size.width-self.rightDistance;
    }
    return self;
}

- (void)addMenuViewWithController:(UIViewController *)viewController {
    [super addMenuViewWithController:viewController];
    
    // 需要展示的尺寸
    CGFloat menuX = CGRectGetWidth(self.frame);
    CGFloat menuY = 0;
    CGFloat menuW = iPad_MenuWidth;
    CGFloat menuH = CGRectGetHeight(self.frame);
    
    // 添加视图 默认的方法
    self.menuView.frame = CGRectMake(menuX, menuY, menuW, menuH);
    viewController.view.frame = self.menuView.bounds;
    [self.menuView addSubview:viewController.view];
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
        self.menuView.transform = CGAffineTransformTranslate(self.menuView.transform, x, 0);
        
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
    self.menuView.hidden = NO;
    self.menuView.alpha = 1.0;
    self.homeView.userInteractionEnabled = NO;
    self.shadowView.hidden = NO;
    self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    CGFloat moveX = -self.rightDistance;
    
    if (animated) {
        // 忽略所有的touch事件
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            
            CGAffineTransform tranform = CGAffineTransformTranslate(CGAffineTransformIdentity, moveX, 0);
            
            weakSelf.homeView.transform = tranform;
            weakSelf.menuView.transform = tranform;
            weakSelf.shadowView.alpha = 1.0;
            weakSelf.minX = weakSelf.homeView.frame.origin.x;
        } completion:^(BOOL finished) {
            weakSelf.sta = kStateMenu;
            
            // 开始接受所有的touch事件
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else {
        CGAffineTransform tranform = CGAffineTransformTranslate(CGAffineTransformIdentity, moveX, 0);
        
        self.homeView.transform = tranform;
        self.menuView.transform = tranform;
        self.shadowView.alpha = 1.0;
        self.minX = self.homeView.frame.origin.x;
        
        self.sta = kStateMenu;
    }
}

- (void)showHomeWithAnimated:(BOOL)animated {
    if (animated) {
        // 忽略所有的touch事件
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.homeView.transform = CGAffineTransformIdentity;
            weakSelf.menuView.transform = CGAffineTransformIdentity;
            weakSelf.shadowView.alpha = 0.0;
        } completion:^(BOOL finished) {
            weakSelf.menuView.hidden = YES;
            weakSelf.menuView.alpha = 0.0;
            weakSelf.homeView.userInteractionEnabled = YES;
            weakSelf.shadowView.hidden = YES;
            weakSelf.sta = kStateHome;
            weakSelf.handlePan.enabled = NO;
            weakSelf.handleTap.enabled = NO;
            
            // 开始接受所有的touch事件
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else {
        self.homeView.transform = CGAffineTransformIdentity;
        self.menuView.transform = CGAffineTransformIdentity;
        self.shadowView.alpha = 0.0;
        
        self.menuView.hidden = YES;
        self.menuView.alpha = 0.0;
        self.homeView.userInteractionEnabled = YES;
        self.shadowView.hidden = YES;
        self.sta = kStateHome;
        self.handlePan.enabled = NO;
        self.handleTap.enabled = NO;
    }
}


@end
