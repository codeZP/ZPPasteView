//
//  PasteButton.m
//  ZPPasteViewDemo
//
//  Created by yueru on 2017/2/6.
//  Copyright © 2017年 yueru. All rights reserved.
//

#import "PasteButton.h"

@interface PasteButton ()

/** 小圆 */
@property (nonatomic, weak) UIView *smallRound;
/** 形状图层 */
@property (nonatomic, weak) CAShapeLayer *shapLayer;

@end

@implementation PasteButton

- (CAShapeLayer *)shapLayer {
    if (!_shapLayer) {
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor redColor].CGColor;
        [self.superview.layer insertSublayer:layer atIndex:0];
        _shapLayer = layer;
    }
    return _shapLayer;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.smallRound removeFromSuperview];
    [self animation];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.masksToBounds = YES;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    
    UIView *samll = [[UIView alloc] initWithFrame:self.frame];
    samll.backgroundColor = self.backgroundColor;
    samll.layer.cornerRadius = self.layer.cornerRadius;
    self.smallRound = samll;
    [self.superview insertSubview:samll belowSubview:self];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (UIGestureRecognizerStateChanged == pan.state) {
        CGPoint offsetP = [pan translationInView:self];
        CGPoint center = self.center;
        center.x += offsetP.x;
        center.y += offsetP.y;
        self.center = center;
        CGFloat distance = [self distanceWithSmall:self.smallRound bigView:self];
        CGFloat roundR = self.bounds.size.width * 0.5;
        roundR -= distance / 10.0;
        self.smallRound.bounds = CGRectMake(0, 0, roundR * 2, roundR * 2);
        self.smallRound.layer.cornerRadius = roundR;
        [pan setTranslation:CGPointZero inView:self];
        
        UIBezierPath *path = [self pathWithSmallView:self.smallRound bigView:self];
        if (self.smallRound.hidden == NO) {
            self.shapLayer.path = path.CGPath;
        }
        
        if (distance > 60) { // 移除
            self.smallRound.hidden = YES;
            [self.shapLayer removeFromSuperlayer];
        }
    }else if (UIGestureRecognizerStateEnded == pan.state) {
        if ([self distanceWithSmall:self.smallRound bigView:self] <= 60) { // 复位
            [self.shapLayer removeFromSuperlayer];
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.center = self.smallRound.center;
            } completion:nil];
        }else { // 做动画
            [self animation];
        }
    }
}

- (void)animation {
    UIImageView *imageV = [[UIImageView alloc] init];
    CGRect rect = CGRectMake(0, 0, 100, 100);
    imageV.bounds = rect;
    imageV.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    [self addSubview:imageV];
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 1; i <= 8; i ++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%zd", i]];
        [images addObject:image];
    }
    imageV.animationImages = images;
    imageV.animationDuration = 1.0;
    [imageV startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (UIBezierPath *)pathWithSmallView:(UIView *)smallView bigView:(UIView *)bigView {
    CGFloat d = [self distanceWithSmall:smallView bigView:bigView];
    if (d <= 0) {
        return nil;
    }
    CGFloat x1 = self.smallRound.center.x;
    CGFloat y1 = self.smallRound.center.y;
    CGFloat x2 = self.center.x;
    CGFloat y2 = self.center.y;
    CGFloat r1 = self.smallRound.bounds.size.width * 0.5;
    CGFloat r2 = self.bounds.size.width * 0.5;
    CGFloat cosΘ = (y2 - y1) / d;
    CGFloat sinΘ = (x2 - x1) / d;
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosΘ, y1 + r1 * sinΘ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosΘ, y1 - r1 * sinΘ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosΘ, y2 - r2 * sinΘ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosΘ, y2 + r2 * sinΘ);
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 * sinΘ, pointA.y + d * 0.5 * cosΘ);
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 * sinΘ, pointB.y + d * 0.5 * cosΘ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}

- (CGFloat)distanceWithSmall:(UIView *)smallView bigView:(UIView *)bigView {
    CGFloat offsetX = bigView.center.x - smallView.center.x;
    CGFloat offsetY = bigView.center.y - smallView.center.y;
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
