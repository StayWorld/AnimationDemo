//
//  BubbleMenuButton.m
//  BuddleBtnDemo
//
//  Created by slash on 2019/5/20.
//  Copyright © 2019 slash. All rights reserved.
//

#import "BubbleMenuButton.h"

#define kAnimationDuration 0.35

@interface BubbleMenuButton ()<UIGestureRecognizerDelegate>
// <#type属性#>
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
// <#type属性#>
@property (nonatomic, strong) NSMutableArray *buttonContainer;
// <#type属性#>
@property (nonatomic, assign) CGRect originFrame;


@end

@implementation BubbleMenuButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefault];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame expansionDirection:(ExpansionDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefault];
        _direction = direction;
    }
    return self;
}

//MARK:life cycle
- (void)initDefault {
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    
    self.direction = DIrectionUp;
    self.animatedHighlighting = YES;
    self.collapseAfterSelection = YES;
    self.animationDuration = kAnimationDuration;
    self.standbyAlpha = 1.0;
    self.highlightAlpha = 0.45;
    self.originFrame = self.frame;
    self.space = 20;
    _isCollapsed = YES;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    self.tapGestureRecognizer.delegate = self;
    
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)_handleTapGesture:(id)sender {
    if (self.tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchLocation = [self.tapGestureRecognizer locationOfTouch:0 inView:self];
        if (_collapseAfterSelection && _isCollapsed == NO && !CGRectContainsPoint(self.homeButtonView.frame, touchLocation)) {
            [self dismissButtons];
        }
    }
}

- (void)_animationWithBlock:(void(^)(void))animationBlock {
    [UIView transitionWithView:self duration:kAnimationDuration options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:animationBlock completion:NULL];
}

- (void)_setTouchHighlighted:(BOOL)highlighted {
    float alphaValue = highlighted ? _highlightAlpha : _standbyAlpha;
    
    if (self.homeButtonView.alpha == alphaValue) {
        return;
    }
    
    if (_animatedHighlighting) {
        [self _animationWithBlock:^{
            if (self.homeButtonView != nil) {
                self.homeButtonView.alpha = alphaValue;
            }
        }];
    } else {
        if (self.homeButtonView != nil) {
            self.homeButtonView.alpha = alphaValue;
        }
    }
}

- (float)_combinedButtonHeight {
    float height = 0;
    for (UIButton *btn in self.buttonContainer) {
        height += btn.frame.size.height + self.space;
    }
    
    return height;
}

- (float)_combinedButtonWidth {
    float width = 0;
    for (UIButton *btn in self.buttonContainer) {
        width += btn.frame.size.width + self.space;
    }
    return width;
}

// 展开后frame

- (void)_prepareForButtonExpansion {
    float buttonHeight = [self _combinedButtonHeight];
    float buttonWidth = [self _combinedButtonWidth];
    
    switch (self.direction) {
        case DIrectionUp: {
            self.homeButtonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            
            CGRect frame = self.frame;
            frame.origin.y -= buttonHeight;
            frame.size.height += buttonHeight;
            self.frame = frame;
        }
            break;
        case DirectionDown: {
            self.homeButtonView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            
            CGRect frame = self.frame;
            frame.size.height += buttonHeight;
            self.frame = frame;
        }
            break;
        case DirectionLeft: {
            self.homeButtonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            CGRect frame = self.frame;
            frame.size.width += buttonWidth;
            self.frame = frame;
        }
        case DirectionRight: {
            self.homeButtonView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
            CGRect frame = self.frame;
            frame.origin.x -= buttonWidth;
            frame.size.width += buttonWidth;
            self.frame = frame;
        }
        default:
            break;
    }
}

- (void)_finishCollapse {
    self.frame = self.originFrame;
}

- (UIView *)_subviewForPoint:(CGPoint)point {
    for (UIView *subview in self.subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            return subview;
        }
    }
    return self;
}

- (NSArray *)_reverseOrderFromArray:(NSArray *)array {
    NSMutableArray *reverseArray = [NSMutableArray array];
    
    for (NSInteger i = array.count - 1; i >= 0; i--) {
        [reverseArray addObject:[array objectAtIndex:i]];
    }
    
    return reverseArray;
}

// MARK: create btn

- (void)setHomeButtonView:(UIView *)homeButtonView {
    if (_homeButtonView != homeButtonView) {
        _homeButtonView = homeButtonView;
    }
    
    if (![_homeButtonView isDescendantOfView:self]) {
//        self.homeButtonView.frame = self.originFrame;
        [self addSubview:self.homeButtonView];
    }
}

- (NSArray *)buttons {
    return [self.buttonContainer copy];
}

// MARK: 处理数组

- (void)addButtons:(NSArray *)buttons {
    assert(buttons != nil);
    
    
    for (NSString *item in buttons) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:item forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 30, 30);
        btn.backgroundColor = [UIColor redColor];
        
        [self addButton:btn];
    }
    
    if (self.homeButtonView != nil) {
        [self bringSubviewToFront:self.homeButtonView];
    }
}

- (void)addButton:(UIButton *)button {
    assert(button != nil);
    
    if (self.buttonContainer == nil) {
        self.buttonContainer = [[NSMutableArray alloc] init];
    }
    
    if (![self.buttonContainer containsObject:button]) {
        [self.buttonContainer addObject:button];
        [self addSubview:button];
        button.hidden = YES;
    }
}

- (void)showButtons {
    
    //TODO: 将要展开回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(bubbleMenuButtonWillExpand:)]) {
        [self.delegate bubbleMenuButtonWillExpand:self];
    }
    
    [self _prepareForButtonExpansion];
    self.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:self.animationDuration];
    [CATransaction setCompletionBlock:^{
        for (UIButton *btn in self.buttonContainer) {
            btn.transform = CGAffineTransformIdentity;
        }
        // TODO: 已经展开回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(bubbleMenuButtonDidExpand:)]) {
            [self.delegate bubbleMenuButtonDidExpand:self];
        }
        
        self.userInteractionEnabled = YES;
        
    }];
    
    NSArray *btnContainer = [self.buttonContainer copy];
    
    if (self.direction == DIrectionUp || self.direction == DirectionLeft) {
        btnContainer = [self _reverseOrderFromArray:btnContainer];
    }
    
    for (NSInteger i = 0; i < btnContainer.count; i++) {
        NSInteger idx = btnContainer.count - (i + 1);
        
        UIButton *btn = [btnContainer objectAtIndex:idx];
        btn.hidden = NO;
        
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        CGPoint originPosition = CGPointZero;
        CGPoint finalPosition = CGPointZero;
        
        switch (self.direction) {
            case DIrectionUp: {
                originPosition = CGPointMake(CGRectGetWidth(self.frame) /2, CGRectGetHeight(self.frame) - CGRectGetHeight(self.homeButtonView.frame));
                finalPosition = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) - CGRectGetHeight(self.homeButtonView.frame) - CGRectGetHeight(btn.frame)/2 - (CGRectGetHeight(btn.frame) + self.space) * idx - self.space);
            }
                break;
            case DirectionDown: {
                originPosition = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.homeButtonView.frame));
                finalPosition = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.homeButtonView.frame) + self.space + (CGRectGetHeight(btn.frame) + self.space) * idx + CGRectGetHeight(btn.frame) / 2);
            }
                break;
            case DirectionLeft: {
                originPosition = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.homeButtonView.frame), CGRectGetHeight(self.frame) / 2);
                finalPosition = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.homeButtonView.frame) - self.space - CGRectGetWidth(btn.frame) / 2 - (CGRectGetWidth(btn.frame) + self.space) * idx, CGRectGetHeight(self.frame) / 2);
            }
                break;
            case  DirectionRight: {
                originPosition = CGPointMake(CGRectGetWidth(self.homeButtonView.frame), CGRectGetHeight(self.frame) / 2);
                finalPosition = CGPointMake(CGRectGetWidth(self.homeButtonView.frame) + self.space + CGRectGetWidth(btn.frame) / 2 + (CGRectGetWidth(btn.frame) + self.space) * idx, CGRectGetHeight(self.frame) / 2);
            }
                break;
            default:
                break;
        }
        
        positionAnimation.fromValue = [NSValue valueWithCGPoint:originPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:finalPosition];
        positionAnimation.duration = self.animationDuration;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.beginTime = CACurrentMediaTime() + (_animationDuration / (CGFloat)self.buttonContainer.count * (CGFloat)i);
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        [btn.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
        btn.layer.position = finalPosition;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.duration = self.animationDuration;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0.01];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1.f];
        scaleAnimation.beginTime = CACurrentMediaTime() + (_animationDuration / (float)self.buttonContainer.count * (float)i) + 0.03f;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        [btn.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        btn.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    }
    [CATransaction commit];
    _isCollapsed = NO;
}

- (void)dismissButtons {
    // TODO:将要撤销回调
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bubbleMenuButtonWillCollapse:)]) {
        [self.delegate bubbleMenuButtonWillCollapse:self];
    }
    
    self.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:self.animationDuration];
    [CATransaction setCompletionBlock:^{
        [self _finishCollapse];
        
        for (UIButton *btn in self.buttonContainer) {
            btn.transform = CGAffineTransformIdentity;
            btn.hidden = YES;
        }
        
        // TODO:撤销完成回调
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(bubbleMenuButtonDidCollapse:)]) {
            [self.delegate respondsToSelector:@selector(bubbleMenuButtonDidCollapse:)];
        }
        
        self.userInteractionEnabled = YES;
    }];
    
    NSInteger idx = 0;
    for (NSInteger i = self.buttonContainer.count - 1; i >= 0; i--) {
        UIButton *button = [self.buttonContainer objectAtIndex:i];
        
        if (self.direction == DirectionDown || self.direction == DirectionLeft) {
            button = [self.buttonContainer objectAtIndex:idx];
        }
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        scaleAnimation.duration = self.animationDuration;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithBool:1.0f];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.01f];
        scaleAnimation.beginTime = CACurrentMediaTime() + (self.animationDuration / (float)self.buttonContainer.count * (float)idx) + 0.03f;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        [button.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        button.transform = CGAffineTransformMakeScale(1.f, 1.f);
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        CGPoint originPostion = button.layer.position;
        CGPoint fianlPostion = CGPointZero;
        
        switch (self.direction) {
            case DirectionLeft:
                fianlPostion = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.homeButtonView.frame), CGRectGetHeight(self.frame) / 2);
                break;
            case DirectionRight:
                fianlPostion = CGPointMake(CGRectGetWidth(self.homeButtonView.frame), CGRectGetHeight(self.frame)/2);
                break;
            case DIrectionUp:
                fianlPostion = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) - CGRectGetHeight(self.homeButtonView.frame));
                break;
            case DirectionDown:
                fianlPostion = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.homeButtonView.frame));
                break;
            default:
                break;
        }
        
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:originPostion];
        positionAnimation.toValue = [NSValue valueWithCGPoint:fianlPostion];
        positionAnimation.duration = self.animationDuration;
        positionAnimation.beginTime = CACurrentMediaTime() + (self.animationDuration/(float)self.buttonContainer.count * (float)idx);
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        [button.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
        button.layer.position = originPostion;
        
        idx++;
    }
    [CATransaction commit];
    
    _isCollapsed = YES;
}

// MARK: Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    if (CGRectContainsPoint(self.homeButtonView.frame, [touch locationInView:self])) {
        [self _setTouchHighlighted:YES];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    [self _setTouchHighlighted:NO];
    
    if (CGRectContainsPoint(self.homeButtonView.frame, [touch locationInView:self])) {
        if (_isCollapsed) {
            [self showButtons];
        } else {
            [self dismissButtons];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self _setTouchHighlighted:NO];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    [self _setTouchHighlighted:CGRectContainsPoint(self.homeButtonView.frame, [touch locationInView:self])];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        if (_isCollapsed) {
            return self;
        } else {
           return [self _subviewForPoint:point];
        }
    }
    
    return hitView;
}

// MARK:UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchLoaction = [touch locationInView:self];
    
    if ([self _subviewForPoint:touchLoaction] != self && _collapseAfterSelection) {
        return YES;
    }
    
    return NO;
}

@end
