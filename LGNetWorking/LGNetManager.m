//
//  LGNetManager.m
//  LGNetWorking
//
//  Created by coco on 16/9/3.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "LGNetManager.h"
#import "LGNetClient.h"

//http请求head信息
#define ClientVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] //appStore版本号
#define ClientType @"3"//1:Android   2:Android Pad    3:iPhone    4:iPad
#define ClientSID [[UIDevice currentDevice].identifierForVendor UUIDString]//设备的唯一标示符Vendor

@implementation LGNetManager
+ (instancetype)shareManager{
    static LGNetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super alloc]init];
    });
    return manager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    return [self shareManager];
}

#pragma mark --请求参数拼接
- (NSDictionary *)setParamsWithParamsBody:(NSDictionary *)paramsBodyDic{
    
    NSDictionary *params =
  @{
    @"Head":
        @{
            @"ClientType":ClientType,
            @"ClientSID" :ClientSID,
            @"ClientVersion":ClientVersion,
            @"UserPid":@"",
            @"UserToken":@""
            },
    @"Body":paramsBodyDic
    };
    
    return params;
}
/**  案例解析  **/
- (void)getHomePageProductListWithStart:(NSString*)start
                             withLength:(NSString*)length
                    withComplationBlock:(CallBackBlock)block{
    NSDictionary *dic = @{@"Start":start,@"Length":length};
    [[LGNetClient shareClient]requestJsonDataWithPath:@"/api/product/IndexProList" withParams:dic withMethodType:POST shouldCache:YES andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        }else{
            
            block(nil,error);
        }
        
    }];
    
}
@end
