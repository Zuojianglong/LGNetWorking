//
//  NSObject+Cache.m
//  LGNetWorking
//
//  Created by coco on 16/9/3.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "NSObject+Cache.h"
#import "MBProgressHUD.h"
#import "NSString+MD5.h"

#define kPath_ResponseCache @"responseCache"
@implementation NSObject (Cache)
+ (void)showHudTipStr:(NSString *)tipStr{
    if (tipStr && tipStr.length>0) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.font = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabel.text = tipStr;
        hud.margin = 10.0;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.5];
        
    }
}

+ (id)loadRequestWithPath:(NSString *)requstPath{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.plst",[self pathInCacheDirectory:kPath_ResponseCache],requstPath.md5Str];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    
    return nil;
    
}
+ (BOOL)saveResonpseData:(NSDictionary *)data toPath:(NSString *)requsetPath{
    if ([self createDirInCache:kPath_ResponseCache]) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self pathInCacheDirectory:kPath_ResponseCache],requsetPath.md5Str];
        BOOL isCache = [[data objectForKey:@"Body"]writeToFile:filePath options:NSDataWritingAtomic error:nil];
        return isCache;
    }else{
        
        return NO;
    }
    
}
//创建文件夹
+ (BOOL)createDirInCache:(NSString *)dirName{
    
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL iscreate = NO;
    if( !(isDir == YES && existed == YES)) {
        
        iscreate = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        iscreate = YES;
    }
    
    return iscreate;
}
//缓存文件夹路径
+ (NSString *)pathInCacheDirectory:(NSString *)fileName{
    NSString *CachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    return [CachePath stringByAppendingPathComponent:fileName];
}
@end
