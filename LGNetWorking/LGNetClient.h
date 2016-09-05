//
//  LGNetClient.h
//  LGNetWorking
//
//  Created by coco on 16/9/3.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void(^callBackBlock)(id data,NSError *error);
typedef NS_ENUM(NSUInteger, NetRequestType) {
    GET = 0,
    POST,
    DELETE,
};
@interface LGNetClient : AFHTTPSessionManager
+ (instancetype)shareClient;

//请求方法
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetRequestType)type
                    shouldCache:(BOOL)shouldAutoCache
                       andBlock:(callBackBlock)block;
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetRequestType)type
                  autoShowError:(BOOL)autoShowError
                    shouldCache:(BOOL)shouldCache
                    andCallBack:(callBackBlock)block;
@end
