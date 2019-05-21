//
//  PathButton.m
//  AnimationDemo
//
//  Created by slash on 2019/5/17.
//  Copyright © 2019 slash. All rights reserved.
//

#import "PathButton.h"

#define kBtnNum 5

@interface PathButton ()
// <#type属性#>
@property (nonatomic, strong) UIImage *normalImage;
// <#type属性#>
@property (nonatomic, strong) UIImage *lightImage;
// <#type属性#>
@property (nonatomic, strong) UIButton *centerBtn;
// <#type属性#>
@property (nonatomic, strong) UIView *bgView;


// <#type属性#>
@property (nonatomic, assign) CGSize foldedSize;
// <#type属性#>
@property (nonatomic, assign) CGSize bloomSize;
// <#type属性#>
@property (nonatomic, assign) CGPoint foldCenter;
// <#type属性#>
@property (nonatomic, assign) CGPoint bloomCenter;
// 记录btn的Center
@property (nonatomic, assign) CGPoint pathCenterBtnBloomCenter;
// <#type属性#>
@property (nonatomic, assign) CGFloat bloomRadius;
// <#type属性#>
@property (nonatomic, strong) NSArray *dataSource;
// <#type属性#>
@property (nonatomic, strong) NSMutableArray *itemArray;




@end

@implementation PathButton

- (instancetype)initWithCenterImage:(UIImage *)image hilightedImage:(UIImage *)hilightedImage {
    self = [self init];
    if (self) {
        self.normalImage = image;
        self.lightImage = hilightedImage;
        self.itemArray = [NSMutableArray array];
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.dataSource = @[@"chooser-moment-icon-camera", @"chooser-moment-icon-music", @"chooser-moment-icon-place", @"chooser-moment-icon-sleep", @"chooser-moment-icon-thought"];
    self.bloomRadius = 150.f;
    
    self.foldedSize = self.normalImage.size;
    self.bloomSize = [UIScreen mainScreen].bounds.size;
    
    self.foldCenter = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height - 255.f);
    self.bloomCenter = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height / 2);
    
    self.frame = CGRectMake(0, 0, self.foldedSize.width, self.foldedSize.height);
    self.center = self.foldCenter;
    
    self.centerBtn.frame = self.frame;
    self.centerBtn.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height /2);
    
    [self addSubview:self.centerBtn];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bloomSize.width, self.bloomSize.height)];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0;
}

- (void)touchCenterWithBtn:(UIButton *)btn {
    btn.selected = !btn.selected;
    [UIView animateWithDuration:0.1575f animations:^{
        btn.transform = CGAffineTransformMakeRotation(btn.selected ? -M_PI_4 : 0);
    }];
    
    btn.selected ? [self pathCenterButtonBloom] : [self pathCenterButtonFold];
}

- (void)pathCenterButtonBloom {
    [self.itemArray removeAllObjects];
    self.pathCenterBtnBloomCenter = self.center;
    
    self.frame = CGRectMake(0, 0, self.bloomSize.width, self.bloomSize.height);
    self.center = CGPointMake(self.bloomSize.width / 2, self.bloomSize.height / 2);
    
    [self insertSubview:self.bgView belowSubview:self.centerBtn];
    
    [UIView animateWithDuration:0.0618f * 3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bgView.alpha = 0.618f;
    } completion:nil];
    self.centerBtn.center = self.pathCenterBtnBloomCenter;
    
    CGFloat basicAngel = 180 / (self.dataSource.count + 1);
    
    for (NSInteger i = 1; i <= self.dataSource.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.backgroundColor = [UIColor whiteColor];
        btn.frame = CGRectMake(0, 0, self.centerBtn.frame.size.width, self.centerBtn.frame.size.width);
        btn.layer.cornerRadius = self.centerBtn.frame.size.width /2;
        btn.layer.masksToBounds = YES;
        btn.transform = CGAffineTransformMakeTranslation(1, 1);
        [btn setImage:[UIImage imageNamed:self.dataSource[i - 1]] forState:UIControlStateNormal];
        
        CGFloat currentAngel = (basicAngel * i)/180;
        
        btn.center = self.pathCenterBtnBloomCenter;
        
        [self insertSubview:btn belowSubview:self.centerBtn];
        
        CGPoint endPoint = [self createEndPointWithRadius:self.bloomRadius andAngel:currentAngel];
        CGPoint farPoint = [self createEndPointWithRadius:self.bloomRadius + 30 andAngel:currentAngel];
        CGPoint nearPoint = [self createEndPointWithRadius:self.bloomRadius - 15 andAngel:currentAngel];
        
        CAAnimationGroup *bloomAnimation = [self bloomAnimationWithEndPoint:endPoint andFarPoint:farPoint andNearPoint:nearPoint];
        
        [btn.layer addAnimation:bloomAnimation forKey:@"bloomAnimation"];
        btn.center = endPoint;
        [self.itemArray addObject:btn];
    }
}

- (void)pathCenterButtonFold {
    for (NSInteger i = 1; i <= self.itemArray.count; i++) {
        UIButton *btn = self.itemArray[i - 1];
        CGFloat currentAngel = i / ((CGFloat)self.itemArray.count + 1);
        CGPoint farPoint = [self createEndPointWithRadius:self.bloomRadius + 5 andAngel:currentAngel];
        
        CAAnimationGroup *animation = [self foldAnimationFromPoint:btn.center WithFarPoint:farPoint];
        
        [btn.layer addAnimation:animation forKey:@"foldAniamtion"];
        
        btn.center = self.pathCenterBtnBloomCenter;
        
    }
    [self resizeToFoldedFrame];
}


- (void)resizeToFoldedFrame {
    [UIView animateWithDuration:0.1f delay:0.35f options:UIViewAnimationOptionCurveLinear animations:^{
        self.bgView.alpha = 0;
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIButton *btn in self.itemArray) {
            [btn performSelector:@selector(removeFromSuperview)];
        }
        self.frame = CGRectMake(0, 0, self.foldedSize.width, self.foldedSize.height);
        self.center = self.foldCenter;
        self.centerBtn.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self.bgView removeFromSuperview];
    });
}

- (CGPoint)createEndPointWithRadius:(CGFloat)itemExpandRadius andAngel:(CGFloat)angel {
    return CGPointMake(self.pathCenterBtnBloomCenter.x - cosf(angel * M_PI) * itemExpandRadius, self.pathCenterBtnBloomCenter.y - sinf(angel * M_PI) * itemExpandRadius);
}

- (CAAnimationGroup *)bloomAnimationWithEndPoint:(CGPoint)endPoint andFarPoint:(CGPoint)farPoint andNearPoint:(CGPoint)nearPoint {
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[@(0.0), @(-M_PI), @(-M_PI * 1.5), @(-M_PI * 2)];
    rotationAnimation.duration = 0.3f;
    rotationAnimation.keyTimes = @[@(0.0), @(0.3), @(0.6), @(1.0)];
    
    CAKeyframeAnimation *movingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.pathCenterBtnBloomCenter.x, self.pathCenterBtnBloomCenter.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, nearPoint.x, nearPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    movingAnimation.path = path;
    movingAnimation.keyTimes = @[@(0.0), @(0.5), @(0.7), @(1.0)];
    movingAnimation.duration = 0.3f;
    CGPathRelease(path);
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = @[movingAnimation, rotationAnimation];
    animations.duration = 0.3f;
    
    return animations;
}

- (CAAnimationGroup *)foldAnimationFromPoint:(CGPoint)endPoint WithFarPoint:(CGPoint)farPoint {
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[@(0), @(M_PI), @(M_PI * 2)];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.duration = 0.35f;
    
    
    CAKeyframeAnimation *movingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, self.pathCenterBtnBloomCenter.x, self.pathCenterBtnBloomCenter.y);
    movingAnimation.keyTimes = @[@(0), @(0.75), @(1.0)];
    movingAnimation.path = path;
    movingAnimation.duration = 0.35f;
    CGPathRelease(path);
    
    CAAnimationGroup *animtions = [CAAnimationGroup animation];
    animtions.animations = @[rotationAnimation, movingAnimation];
    animtions.duration = 0.35f;
    return animtions;
}


- (UIButton *)centerBtn {
    if (_centerBtn == nil) {
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerBtn setImage:self.normalImage forState:UIControlStateNormal];
        [_centerBtn setImage:self.lightImage forState:UIControlStateHighlighted];
        [_centerBtn addTarget:self action:@selector(touchCenterWithBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerBtn;
}

@end
