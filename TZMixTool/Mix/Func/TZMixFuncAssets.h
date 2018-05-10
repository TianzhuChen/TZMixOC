//
//  TZMixFuncAssets.h
//  TZMixTool
//
//  Created by CXY on 2018/5/5.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZMixCacheFile.h"
#import "TZMixFuncBase.h"
/**
 修改图片名称
 */
@interface TZMixFuncAssets : TZMixFuncBase
@property (nonatomic,strong) NSMutableArray<NSString *> *xcassetsPath;//资源文件根路径
@end
