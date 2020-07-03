//
//  ViewController.m
//  ShareHelper
//
//  Created by 马定坤 on 2020/7/3.
//  Copyright © 2020 mdkmdk. All rights reserved.
//

#import "ViewController.h"
#import "AoJiaoShareManager.h"
@interface ViewController ()
@property (nonatomic,strong)UIButton *shareBtn;
@end

@implementation ViewController

-(UIButton *)shareBtn{
    if (_shareBtn == nil) {
        _shareBtn = [UIButton new];
        _shareBtn.frame = CGRectMake(0, 50, 40, 20);
        [_shareBtn setTitle:@"分享" forState:0];
        _shareBtn.backgroundColor = UIColor.redColor;
        [_shareBtn addTarget:self action:@selector(sharebtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.shareBtn];
}

-(void)sharebtnClick{
    [[AoJiaoShareManager sharedInstance]showWithTitle:@"魂器学院" image:@"https://img1.gtimg.com/10/1048/104857/10485731_980x1200_0.jpg" intro:@"魂器学院" url:@"https://img1.gtimg.com/10/1048/104857/10485731_980x1200_0.jpg" dataDic:nil];
}

@end
