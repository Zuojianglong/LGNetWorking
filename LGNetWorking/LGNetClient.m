//
//  LGNetClient.m
//  LGNetWorking
//
//  Created by coco on 16/9/3.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "LGNetClient.h"
#import "NSObject+Cache.h"
#import "AFNetworking.h"

#define DebugLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define Base_Url @"http://175.102.15.84:8011"

@implementation LGNetClient

+ (instancetype)shareClient{
    
    static LGNetClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[super alloc]initWithBaseURL:[NSURL URLWithString:Base_Url]];
    });
    
    return client;
}
/*
 重写父类的方法，设置更多的请求相关属性，比如超时时间，缓存。返回数据类型，请求类型。请求头信息等等。。。
 */
- (instancetype)initWithBaseURL:(NSURL *)url{
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    self.requestSerializer.timeoutInterval = 6.0;
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
    
    AFJSONResponseSerializer *res = [AFJSONResponseSerializer serializer];
    res.removesKeysWithNullValues = YES;
    self.responseSerializer = res;
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    
    self.securityPolicy.allowInvalidCertificates = YES;
    
    return self;
}

//请求方法
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetRequestType)type
                    shouldCache:(BOOL)shouldAutoCache
                       andBlock:(callBackBlock)block{
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:type autoShowError:YES shouldCache:shouldAutoCache andCallBack:block];
}
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetRequestType)type
                  autoShowError:(BOOL)autoShowError
                      shouldCache:(BOOL)shouldCache
                    andCallBack:(callBackBlock)block{
    //请求的路径错误 直接退出
    if (!aPath || aPath.length <= 0) {
        return;
    }
   //获得本地缓存的路径
    NSMutableString *localPath = aPath.mutableCopy;
    if (params) {
        [localPath appendString:[[params objectForKey:@"Head"] objectForKey:@"UserToken"]];
    }
    //根据请求方式，设置不同的请求策略.添加缓存机制，如果请求数据失败就去加载本地数据
    switch (type) {
        case GET:{
            [self GET:aPath parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                //进度
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DebugLog(@"\n===========response===========\n%@:\n%@",aPath,responseObject);
                NSError *error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    [NSObject showHudTipStr:error.localizedDescription];
                    
                    responseObject = [NSObject loadRequestWithPath:aPath];

                    block(responseObject,error);
                    DebugLog(@"\n===========response===========\n%@:\n%@:\n%@", responseObject, aPath,error);
                }else{
                    //请求成功，并且判断做缓存
                    if (shouldCache) {
                        if ([NSObject saveResonpseData:responseObject toPath:localPath]){
                        DebugLog(@"缓存成功");
                        }
                    }
                    block(responseObject,nil);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               //
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                [NSObject showHudTipStr:error.localizedDescription];
                id responseObject = [NSObject loadRequestWithPath:localPath];
                block (responseObject,error);
            }];
        }
            break;
        case POST:
        {
            [self POST:aPath parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                DebugLog(@"__%f",[uploadProgress fractionCompleted]);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                NSError * error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    [NSObject showHudTipStr:error.localizedDescription];
                    responseObject=[NSObject loadRequestWithPath:localPath];
                    block(responseObject,error);
                    DebugLog(@"\n===========response===========\n%@:\n%@:\n%@", responseObject, aPath,error);
                }
                else{
                    if(shouldCache){
                        if ([NSObject saveResonpseData:responseObject toPath:localPath]){
                            DebugLog(@"缓存成功");
                        }
                    }
                }
                block(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [NSObject showHudTipStr:error.localizedDescription];
                id responseObject = [NSObject loadRequestWithPath:localPath];
                block(responseObject, error);
                DebugLog(@"\n===========response===========\n%@:\n%@:\n%@", aPath, error,responseObject);
            }];

        }
            break;
        case DELETE:
        {
            [self DELETE:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSError *error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                   block(nil, error);
                }else{
                    DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                    if(shouldCache){
                        [NSObject saveResonpseData:responseObject toPath:localPath];
                        DebugLog(@"缓存成功");
                    }
                    block(responseObject, nil);
                    
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                [NSObject showHudTipStr:error.localizedDescription];
                block(nil, error);
            }];
        }
            break;
            
        default:
            break;
    }
}
//请求出错反馈
- (NSError *)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError{
    NSError *error = nil;
    //code为非10000时，表示有错
    NSNumber *resultCode = responseJSON[@"Head"][@"ErrorCode"];
    if ([resultCode integerValue] != 10000) {
        error = [NSError errorWithDomain:Base_Url code:resultCode.integerValue userInfo:responseJSON];
        
        if (autoShowError) {
            [NSObject showHudTipStr:[[responseJSON valueForKey:@"Head"] objectForKey:@"Msg"]];
        }
        
    }
    return error;
}
@end
