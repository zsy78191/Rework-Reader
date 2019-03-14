//
//  PWToastView.m
//  PasswordX
//
//  Created by 张超 on 15/8/27.
//  Copyright (c) 2015年 Gerinn. All rights reserved.
//

#import "PWToastView.h"
@import pop;
@import Classy;
//#import "UIColor+Additions.h"
@interface PWToastView ()
{
    
}
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) UILabel* toast_label;
@property (nonatomic, assign) NSInteger count;


@end

@implementation PWToastView

+ (instancetype)sharedInstance
{
    static PWToastView * _g_view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = [UIScreen mainScreen].bounds.size;
        _g_view = [[PWToastView alloc] initWithFrame:CGRectMake(0, 0, size.width, 120)];
    });
    return _g_view;
}

- (UILabel *)toast_label
{
    if (!_toast_label) {
        _toast_label = [[UILabel alloc] initWithFrame:CGRectMake(28, 10, self.frame.size.width - 56, 120)];
        [self addSubview:_toast_label];
//        [_toast_label setFont:[UIFont fontWithName:@"NotoSansHans-DemiLight" size:14]];
//        [_toast_label setTextColor:[UIColor colorWithRGBHex:0x6A758F]];
//        [_toast_label setTextColor:[UIColor blackColor]];
        _toast_label.numberOfLines = 2;
        [_toast_label setAdjustsFontSizeToFitWidth:YES];
        _toast_label.cas_styleClass = @"ToastLabel";
    }
    return _toast_label;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        UIView* c = [[UIView alloc] initWithFrame:({
            CGRect r = self.bounds;
            r.origin.x += 8;
            r.origin.y += 28;
            r.size.width -= 16;
            r.size.height -= 36;
            r;
        })];
        visualEffectView.frame = c.bounds;
        [c addSubview:visualEffectView];
        [c setBackgroundColor:[UIColor clearColor]];
        c.layer.cornerRadius = 5;
        [c setClipsToBounds:YES];
        [self addSubview: c];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)count_it:(NSTimer*)timer
{
    self.count ++;
    if (self.count == 3) {
        [self dismiss];
    }
}

+ (void)showText:(NSString *)text
{
    PWToastView* t = [PWToastView sharedInstance];
    if (t.show) {
        t.toast_label.text = text;
    }
    else
    {
        t.show = YES;
        CGSize size = [UIScreen mainScreen].bounds.size;
        t.transform = CGAffineTransformMakeTranslation(0, size.height);
        [[UIApplication sharedApplication].keyWindow addSubview:t];
        
//        CGRect r = t.frame;
        
        
        POPSpringAnimation* spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        spring.springBounciness = 12;
        spring.fromValue = [NSValue valueWithCGRect:({
            CGRect f = t.frame;
            f.origin.y = -f.size.height;
            f;
        })];
        spring.toValue = [NSValue valueWithCGRect:({
            CGRect f = t.frame;
            f.origin.y = -f.size.height + 120;
            f;
        })];
        [t pop_addAnimation:spring forKey:@"first"];
        
        t.toast_label.text = text;
    }
    
    t.count = 0;
    [t.timer invalidate];
    t.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:t selector:@selector(count_it:) userInfo:nil repeats:YES];
    [t.timer fire];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

- (void)dismiss
{
    [self.timer invalidate];
    if (!self.show) {
        return;
    }
    
    self.show = NO;
    
//    CGRect r = self.frame;
//    [CustomEasingAnimation easingFrom:60 to:0 interval:0.24 timing:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] block:^(CGFloat value) {
//        self.frame = ({
//            CGRect rect = r;
//            rect.origin.y = - rect.size.height + value;
//            rect;
//        });
//    } comeplte:^{
//
//    }];
//    CGSize size = [UIScreen mainScreen].bounds.size;
    
    POPSpringAnimation* spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    spring.springBounciness = 8;
    spring.toValue = [NSValue valueWithCGRect:({
        CGRect f = self.frame;
        f.origin.y = -f.size.height;
        f;
    })];
    spring.fromValue = [NSValue valueWithCGRect:({
        CGRect f = self.frame;
        f.origin.y = -f.size.height + 120;
        f;
    })];
    [self pop_addAnimation:spring forKey:@"second"];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
