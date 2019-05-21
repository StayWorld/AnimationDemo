//
//  BubbleMenuButton.h
//  BuddleBtnDemo
//
//  Created by slash on 2019/5/20.
//  Copyright © 2019 slash. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BubbleMenuButton;

@protocol BubbleMenuButtonDelegate <NSObject>

@optional
- (void)bubbleMenuButtonWillExpand:(BubbleMenuButton *)expandableView;
- (void)bubbleMenuButtonDidExpand:(BubbleMenuButton *)expandableView;

- (void)bubbleMenuButtonWillCollapse:(BubbleMenuButton *)expandableView;
- (void)bubbleMenuButtonDidCollapse:(BubbleMenuButton *)expandableView;

@end


typedef NS_ENUM(NSInteger, ExpansionDirection) {
    DirectionLeft = 0,
    DirectionRight,
    DIrectionUp,
    DirectionDown
};

@interface BubbleMenuButton : UIView
// <#type属性#>
@property (nonatomic, copy, readonly) NSArray *buttons;
// <#type属性#>
@property (nonatomic, strong) UIView *homeButtonView;
// <#type属性#>
@property (nonatomic, readonly) BOOL isCollapsed;
// <#type属性#>
@property (nonatomic, assign) ExpansionDirection direction;
// <#type属性#>
@property (nonatomic, assign) CGFloat space;
// <#type属性#>
@property (nonatomic, assign) BOOL animatedHighlighting;
// <#type属性#>
@property (nonatomic) BOOL collapseAfterSelection;
// <#type属性#>
@property (nonatomic) float animationDuration;
// <#type属性#>
@property (nonatomic) float standbyAlpha;
// <#type属性#>
@property (nonatomic) float highlightAlpha;
// <#type属性#>
@property (nonatomic, weak) id<BubbleMenuButtonDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame expansionDirection:(ExpansionDirection)direction;


- (void)addButtons:(NSArray *)buttons;
- (void)addButton:(UIButton *)button;
- (void)showButtons;
- (void)dismissButtons;

@end

NS_ASSUME_NONNULL_END
