//
//  TZMixManager.h
//  TZMixTool
//
//  Created by CXY on 2018/5/3.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JQFMDB.h"
#import "TZMixCacheFile.h"
#import "TZMixConfig.h"

#define KeyProjectExten @"xcodeproj" //项目扩展
#define KeyProjectFileName @"project.pbxproj" //项目文件

typedef void(^TZMixCompleteBlock)(void);
@interface TZMixManager : NSObject
@property (nonatomic,copy,readonly) NSString *dbPath;
@property (nonatomic,strong,readonly) TZMixConfig *config;
@property (nonatomic,copy) NSString *modifiedClassNamePrefix;//修改后的类名前缀，只有在isAddClassPrefix为yes时使用

@property (nonatomic,copy) NSMutableString *logStr;

@property (nonatomic,strong) NSMutableArray<NSString *> *cacheFilePathArray;
@property (nonatomic,strong) NSMutableArray<NSString *> *cacheXcassetsPathArray;//Assets资源路径，如果开启了资源重命名
@property (nonatomic,strong) NSMutableDictionary<NSString *,TZMixCacheFile *> *cacheData;//缓存新旧类名

+(instancetype)SharedManager;
-(void)startWithConfig:(TZMixConfig *)config completeBlock:(TZMixCompleteBlock)completeBlock;
-(NSString *)createMixName:(NSArray<NSString *> *)nameArray;
-(NSString *)createMixClassName;
-(NSString *)RandomString:(NSInteger)length;
-(void)updateLog:(NSString *)log;
@end
