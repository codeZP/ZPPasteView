//
//  DrawView.m
//  ceshi
//
//  Created by yueru on 2017/2/6.
//  Copyright © 2017年 yueru. All rights reserved.
//

#import "DrawView.h"

@interface DrawView ()

/** 路径 */
@property (nonatomic, strong) UIBezierPath *path;
/** 粒子 */
@property (nonatomic, weak) CALayer *dotLayer;
@end

@implementation DrawView

- (UIBezierPath *)path {
    if (!_path) {
        _path = [UIBezierPath bezierPath];
    }
    return _path;
}

- (void)start {
    // 添加动画
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position";
    anim.path = self.path.CGPath;
    anim.repeatCount = MAXFLOAT;
    anim.duration = 3;
    [self.dotLayer addAnimation:anim forKey:nil];
}

- (void)clearn {
    [self.dotLayer removeAllAnimations];
    [self.path removeAllPoints];
    [self setNeedsDisplay];
}

+ (Class)layerClass {
    return [CAReplicatorLayer class];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 添加手势
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    // 得到复制层
    CAReplicatorLayer *repl = (CAReplicatorLayer *)self.layer;
    // 创建粒子
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(-40, 0, 20, 20);
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    layer.backgroundColor = [UIColor redColor].CGColor;
    [repl addSublayer:layer];
    self.dotLayer = layer;
    repl.instanceCount = 20;
    repl.instanceDelay = 0.5;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint curP = [pan locationInView:self];
    if (UIGestureRecognizerStateBegan == pan.state) {
        [self.path moveToPoint:curP];
    }else if (UIGestureRecognizerStateChanged == pan.state) {
        [self.path addLineToPoint:curP];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.path stroke];
}


@end
