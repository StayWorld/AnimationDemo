//
//  ViewController.m
//  AnimationDemo
//
//  Created by slash on 2019/5/17.
//  Copyright © 2019 slash. All rights reserved.
//

#import "ViewController.h"
#import "PathButton.h"

@interface ViewController ()
// <#type属性#>
@property (nonatomic, strong) PathButton *pathBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.pathBtn.center = CGPointMake(self.view.frame.size.width / 2 - CGRectGetWidth(self.pathBtn.frame)/2, self.view.frame.size. height - 200);
    [self.view addSubview:self.pathBtn];
}

- (PathButton *)pathBtn {
    if (_pathBtn == nil) {
        _pathBtn = [[PathButton alloc] initWithCenterImage:[UIImage imageNamed:@"chooser-button-input"] hilightedImage:[UIImage imageNamed:@"chooser-button-input-highlighted"]];
    }
    return _pathBtn;
}

@end
