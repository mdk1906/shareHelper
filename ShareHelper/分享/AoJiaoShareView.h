//
//  AoJiaoShareView.h
//  occ++lua
//
//  Created by 马定坤 on 2020/6/23.
//  Copyright © 2020 mdkmdk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AoJiaoShareView : UIView
-(instancetype)initWithFrame:(CGRect)frame withVC:(UIViewController *)vc;
- (void)showWithCompleteBlock:(void (^)(NSInteger))block;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
