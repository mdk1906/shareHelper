//
//  AoJiaoShareManager.m
//  occ++lua
//
//  Created by 马定坤 on 2020/6/23.
//  Copyright © 2020 mdkmdk. All rights reserved.
//

//微博id
#define WeiboAppKey         @"" //新浪微博Appkey
#define WeiboRedirectURI    @"" //新浪微博回调地址
//微信id
#define WeixinAppKey        @"" //微信Appkey
#define WeixinAppSecret     @"" //微信appAppSecret
#define WeixinMINIID        @"" //微信小程序id
#define WeixinUniversalLink @"" //微信开发者Universal Link
//腾讯id
#define QQAppKey            @"" //QQ分享Appkey
#define QQUniversalLink     @"" //QQUniversalLink

#define WEAK_SELF __weak __typeof(self)weakSelf = self

#define STRONG_SELF STRONG_SELF_NIL_RETURN

#define STRONG_SELF_NIL_RETURN __strong __typeof(weakSelf)self = weakSelf; if ( ! self) return ;

#undef    DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class * __nonnull)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once(&once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#import "AoJiaoShareManager.h"
#import "AoJiaoShareView.h"

#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"

@interface AoJiaoShareManager ()
<
WXApiDelegate,
WeiboSDKDelegate,
QQApiInterfaceDelegate,
TencentSessionDelegate
>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@property (nonatomic, copy) NSDictionary *wbShareInfo;

@property (nonatomic, copy) NSString *wbToken;

@property (nonatomic, strong) NSMutableArray *permissionArray;

@property (assign) BOOL share;

@end
@implementation AoJiaoShareManager

DEF_SINGLETON(AoJiaoShareManager);

#pragma mark - 单例init
- (instancetype)init
{
    self = [super init];
    
    [WeiboSDK registerApp:WeiboAppKey];
    [WXApi registerApp:WeixinAppKey universalLink:WeixinUniversalLink];
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppKey andUniversalLink:QQUniversalLink andDelegate:self];
    
    return self;
}

- (void)dealloc {
    NSLog(@"[%@ call %@]", [self class], NSStringFromSelector(_cmd));
}

#pragma mark - 分享
+ (BOOL)handleOpenUrl:(nullable NSURL *)url sourceApplication:(nullable NSString *)sourceApplication
{
    NSString *urlstr = [NSString stringWithFormat:@"%@",url];
    if ([urlstr containsString:WeixinAppKey]) {
        return [WXApi handleOpenURL:url delegate:[AoJiaoShareManager sharedInstance]];
    }
    else if ([sourceApplication isEqualToString:@"com.tencent.mqq"] ||[sourceApplication isEqualToString:@"com.tencent.mipadqq"]) {
        [QQApiInterface handleOpenURL:url delegate:[AoJiaoShareManager sharedInstance]];
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([sourceApplication isEqualToString:@"com.sina.weibo"] ||[sourceApplication isEqualToString:@"com.sina.weibohd"]) {
        return [WeiboSDK handleOpenURL:url delegate:[AoJiaoShareManager sharedInstance]];
    }
    
    return NO;
}

- (void)showWithTitle:(NSString * __nullable)aTitle image:(NSString * __nullable)aImage intro:(NSString * __nullable)aIntro url:(NSString * __nullable)aUrl dataDic:(NSDictionary * __nullable)adataDic
{
    self.share = true;
    
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *rootViewController = window.rootViewController;
    AoJiaoShareView *shareView = [[AoJiaoShareView alloc] initWithFrame:CGRectMake(0, 0, rootViewController.view.bounds.size.width, rootViewController.view.bounds.size.height) withVC:rootViewController];
    [rootViewController.view addSubview:shareView];
    
    WEAK_SELF;
    [shareView showWithCompleteBlock:^(NSInteger selectedIndex) {
        STRONG_SELF;
        [self showWithTitle:aTitle image:aImage intro:aIntro url:aUrl selectedIndex:selectedIndex dataDic:adataDic];
    }];
}

- (void)showWithTitle:(NSString * __nullable)aTitle image:(NSString * __nullable)aImage intro:(NSString * __nullable)aIntro url:(NSString * __nullable)aUrl selectedIndex:(NSInteger)selectedIndex dataDic:(NSDictionary * __nullable)adataDic
{
    
    NSString *title = aTitle.copy;
    NSString *intro = aIntro.copy;
    NSURL *imageUrl = [NSURL URLWithString:aImage.copy];
    
    NSString *url = [aUrl.copy stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *text = [NSString stringWithFormat:@"《%@》#魂器学院#", title];
    
    if (selectedIndex == 0) {
           //微博分享
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"title"] = aTitle;
            params[@"intro"] = aIntro;
            params[@"image"] = aImage;
            params[@"url"] = aUrl;
            self.wbShareInfo = params;
            
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = WeiboRedirectURI;
            authRequest.scope = @"all";
            [WeiboSDK sendRequest:authRequest];
        
        
    }
    else if (selectedIndex == 1 || selectedIndex == 3) {
        if (![WXApi isWXAppInstalled]) {
            NSLog(@"无法使用微信分享");
            return ;
        }
        
        if (![WXApi isWXAppSupportApi]) {
            NSLog(@"无法使用微信分享");
            return ;
        }
        if (adataDic == nil) {
            //没有小程序分享功能
            
               
            WXImageObject *imageObject = [WXImageObject object];
            imageObject.imageData = [NSData dataWithContentsOfURL:imageUrl];

            WXMediaMessage *message = [WXMediaMessage message];
            message.thumbData = [NSData dataWithContentsOfURL:imageUrl];
            message.mediaObject = imageObject;

            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            if (selectedIndex == 1) {
                req.scene = WXSceneSession;
            }
            else {
                req.scene = WXSceneTimeline;

            }
            [WXApi sendReq:req completion:nil];
            
        }
        else{
            //有小程序分享功能
            WXMiniProgramObject *object = [WXMiniProgramObject object];
            object.webpageUrl = url;
            object.userName = WeixinMINIID;
            object.path = [NSString stringWithFormat:@"pages/%@?id=%@",adataDic[@"type"],adataDic[@"workId"]];
            object.hdImageData = [NSData dataWithContentsOfURL:imageUrl];
            object.withShareTicket = NO;
            object.miniProgramType = WXMiniProgramTypeRelease;
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            message.description = intro;
            message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
            //使用WXMiniProgramObject的hdImageData属性
            message.mediaObject = object;

            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneSession;  //目前只支持会话
            [WXApi sendReq:req completion:^(BOOL success) {
                NSLog(@"微信分享成功");
            }];
            if (selectedIndex == 1) {
                req.scene = WXSceneSession;
            }
            else {
                //            req.scene = WXSceneTimeline;
                NSLog(@"小程序暂时不能分享至朋友圈");
            }
            
           [WXApi sendReq:req completion:^(BOOL success) {
                NSLog(@"微信分享成功");
            }];
        }
        
        
    }
    else if (selectedIndex == 2) {
        if (![QQApiInterface isQQInstalled]) {
            NSLog(@"无法使用QQ分享");
            return;
        }
        
        if (![QQApiInterface isQQSupportApi]) {
            NSLog(@"无法使用QQ分享");
            return;
        }
        
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url]
                                                            title:title
                                                      description:intro
                                                  previewImageURL:imageUrl];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
    }
}

//分享成功任务完成
-(void)shareTaskFinishd{
    NSLog(@"分享任务完成");
    NSDictionary *dict = @{@"status":@(1)};
    [[NSNotificationCenter defaultCenter]postNotificationName:AOJIAO_SHARE_FINISH_SUCCESS_KEY object:dict];
    
}

#pragma mark -weibo Delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"didReceiveWeiboRequest");
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSLog(@"didReceiveWeiboResponse");
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        WBSendMessageToWeiboResponse *res = (id)response;
        if (res.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            NSLog(@"分享成功");
            [self shareTaskFinishd];
        }
        else if (res.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            NSLog(@"分享取消了");
        }
        else {
            NSLog(@"分享失败");
        }
    }
}


#pragma mark - QQ || weixin delegate
-(void)onReq:(id)req
{
    NSLog(@"onReq");
}

- (void)onResp:(id)resp
{
    NSLog(@"onResp");
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *qq = resp;
        if (!self.share) {
            return;
        }
        if ([qq.result isEqualToString:@"0"]) {
            NSLog(@"分享成功");
            [self shareTaskFinishd];
        }
        else if ([qq.result isEqualToString:@"-4"]) {
            NSLog(@"分享取消了");
        }
        else {
            NSLog(@"分享失败");
        }
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        BaseResp *weixin = resp;
        if (weixin.errCode == WXSuccess) {
            NSLog(@"分享成功");
            [self shareTaskFinishd];
        }
        else if (weixin.errCode == WXErrCodeUserCancel) {
            NSLog(@"分享取消了");
        }
        else {
            NSLog(@"分享失败");
        }
    }
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response
{
    
}

- (void)tencentDidLogin {
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

@end
