//
//  ViewController.m
//  BuddleBtnDemo
//
//  Created by slash on 2019/5/20.
//  Copyright © 2019 slash. All rights reserved.
//

#import "ViewController.h"
#import "BubbleMenuButton.h"

#define kWIDTH [UIScreen mainScreen].bounds.size.width
#define kHEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
// <#type属性#>
@property (nonatomic, strong) BubbleMenuButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *arr = @[@"A", @"B", @"C", @"D", @"E", @"F"];
//    UIView *homeView = [[UIView alloc] init];
//    homeView.backgroundColor = [UIColor redColor];
    [self.btn addButtons:arr];
    [self.view addSubview:self.btn];
}

- (BubbleMenuButton *)btn {
    if (_btn == nil) {
        _btn = [[BubbleMenuButton alloc] initWithFrame:CGRectMake(50, kHEIGHT - 40, 40, 40) expansionDirection:DIrectionUp];
        self.btn.homeButtonView = [self createHomeButtonView];
    }
    return _btn;
}

- (UILabel *)createHomeButtonView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    
    label.text = @"Tap";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = label.frame.size.height / 2.f;
    label.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    label.clipsToBounds = YES;
    
    return label;
}

@end
