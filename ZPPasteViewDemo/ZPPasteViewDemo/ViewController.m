//
//  ViewController.m
//  ceshi
//
//  Created by yueru on 2017/2/6.
//  Copyright © 2017年 yueru. All rights reserved.
//

#import "ViewController.h"
#import "DrawView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet DrawView *drawView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)start:(UIButton *)sender {
    [self.drawView start];
}
- (IBAction)clearn:(UIButton *)sender {
    [self.drawView clearn];
}

@end
