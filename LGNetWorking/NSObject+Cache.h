//
//  NSObject+Cache.h
//  LGNetWorking
//
//  Created by coco on 16/9/3.
//  Copyright © 2016年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Cache)
//HUD 提示卡
+ (void)showHudTipStr:(NSString *)tipStr;
//加载缓存数据
+ (id)loadRequestWithPath:(NSString *)requstPath;
//写入本地缓存
+ (BOOL)saveResonpseData:(NSDictionary *)data toPath:(NSString *)requsetPath;
@end
