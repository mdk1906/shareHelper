//
//  AoJiaoShareManager.h
//  occ++lua
//
//  Created by 马定坤 on 2020/6/23.
//  Copyright © 2020 mdkmdk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AOJIAO_SHARE_FINISH_SUCCESS_KEY @"AOJIAO_SHARE_FINISH_SUCCESS_KEY"
#define AOJIAO_SHARE_FINISH_FAIL_KEY @"AOJIAO_SHARE_FINISH_FAIL_KEY"

@interface AoJiaoShareManager : NSObject


+ (AoJiaoShareManager * __nonnull)sharedInstance;

+ (BOOL)handleOpenUrl:(nullable NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

- (void)showWithTitle:(NSString * __nullable)aTitle image:(NSString * __nullable)aImage intro:(NSString * __nullable)aIntro url:(NSString * __nullable)aUrl dataDic:(NSDictionary * __nullable)adataDic;


@end

NS_ASSUME_NONNULL_END
