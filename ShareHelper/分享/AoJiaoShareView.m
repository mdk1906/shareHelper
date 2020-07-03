//
//  AoJiaoShareView.m
//  occ++lua
//
//  Created by 马定坤 on 2020/6/23.
//  Copyright © 2020 mdkmdk. All rights reserved.
//

#define WEAK_SELF __weak typeof(self)weakSelf            = self

#define STRONG_SELF STRONG_SELF_NIL_RETURN
#define STRONG_SELF_NIL_RETURN __strong typeof(weakSelf)self = weakSelf; if ( ! self) return ;

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kMaxX(X) CGRectGetMaxX(X)
#define kMaxY(Y) CGRectGetMaxY(Y)


#import "AoJiaoShareView.h"
@interface AoJiaoShareView ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (nonatomic, copy) void (^block)(NSInteger);

@property (nonatomic, copy) NSArray *resources;
@end
@implementation AoJiaoShareView




-(instancetype)initWithFrame:(CGRect)frame withVC:(UIViewController *)vc{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViewWithVC:vc];
    }
    return self;
}

#pragma mark -懒加载
-(NSArray *)resources{
    if (_resources == nil) {
        _resources =@[
        @[@"微博", @"share_icon0"],
        @[@"微信", @"share_icon1"],
        @[@"QQ", @"share_icon2"],
        @[@"朋友圈", @"share_icon3"],
        ];
    }
    return _resources;
}

-(UIView *)bgView{
    if (_bgView == nil) {
        _bgView = [UIView new];
    }
    return _bgView;
}

-(UIButton *)cancelBtn{
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.backgroundColor = [UIColor blueColor];
        [_cancelBtn setTitle:@"取消" forState:0];
        [_cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitleColor:UIColor.whiteColor forState:0];
    }
    return _cancelBtn;
}

-(UITapGestureRecognizer*)tap{
    if (_tap == nil) {
        _tap = [[UITapGestureRecognizer alloc] init];
        [_tap addTarget:self action:@selector(onTap:)];
        _tap.numberOfTapsRequired = 1;
        _tap.delegate = self;
    }
    return _tap;
}
#pragma mark -UIInit
-(void)createViewWithVC:(UIViewController *)vc{
    
    
    self.bgView.frame = CGRectMake(0, 0, UISCREEN_WIDTH,UISCREEN_HEIGHT);
    _bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgView];
    
    [_bgView addGestureRecognizer:self.tap];
    
    UIImageView *bgImg = [UIImageView new];
    bgImg.frame = CGRectMake(0, vc.view.bounds.size.height-50-100, vc.view.bounds.size.width, 100);
    bgImg.backgroundColor = [UIColor greenColor];
    bgImg.userInteractionEnabled = YES;
    [_bgView addSubview:bgImg];
    
    for (int i = 0; i<self.resources.count; i++) {
        float jiange = (UISCREEN_WIDTH - self.resources.count*50)/5;
        UIImageView *btnimg = [UIImageView new];
        btnimg.frame = CGRectMake(i*50 + jiange * (i+1), 10, 50, 60);
        btnimg.backgroundColor = UIColor.blueColor;
        btnimg.image = [UIImage imageNamed:self.resources[i][1]];
        [bgImg addSubview:btnimg];
        
        UILabel *titleLab = [UILabel new];
        titleLab.frame = CGRectMake(i*50 + jiange  * (i+1), kMaxY(btnimg.frame) + 5, 50, 20);
        titleLab.text = self.resources[i][0];
        titleLab.font = [UIFont systemFontOfSize:15];
        titleLab.textAlignment = 1;
        titleLab.textColor = [UIColor blackColor];
        [bgImg addSubview:titleLab];
        
        UIButton *btn = [UIButton new];
        btn.frame = CGRectMake(i*50 +  jiange  * (i+1), 0, 50, 100);
        btn.tag = i;
        [btn addTarget:self action:@selector(onPressedShareBtn:) forControlEvents:UIControlEventTouchUpInside];
        [bgImg addSubview:btn];
        UIButton *sharebtn = [UIButton new];
        btn.frame = CGRectMake(0, 0, 140, 100);
        
    }
    
    self.cancelBtn.frame = CGRectMake(0, kMaxY(bgImg.frame), UISCREEN_WIDTH, 50);
    [_bgView addSubview:_cancelBtn];
    
}

- (void)showWithCompleteBlock:(void (^)(NSInteger))block;
{
    self.block = block;
    WEAK_SELF;
    [UIView animateWithDuration:0 animations:^{
        STRONG_SELF;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    }];
}

- (void)hide {
    WEAK_SELF;
    [UIView animateWithDuration:0 animations:^{
        STRONG_SELF;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        STRONG_SELF;
        [self removeFromSuperview];
    }];
}

- (void)onTap:(id)sender {
    [self hide];
}

- (void)onPressedShareBtn:(UIButton *)sender {
    if (self.block) {
        self.block(sender.tag);
    }
    [self hide];
}

#pragma mark - UIGestureRecognizerDelegate
 
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([touch.view isEqual:self.bgView])
    {
        return YES;
    }
    else
    {
        return NO;
    }

}
@end
