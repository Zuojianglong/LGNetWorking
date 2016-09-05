//
//  LGNetManager.h
//  LGNetWorking
//
//  Created by coco on 16/9/3.
//  Copyright © 2016年 coco. All rights reserved.
//
               /*该类提供了工程所需的所有API接口*/
#import <Foundation/Foundation.h>

@interface LGNetManager : NSObject
//请求的结果以block的形式返回
typedef void(^CallBackBlock)(id data,NSError * error);
@end
