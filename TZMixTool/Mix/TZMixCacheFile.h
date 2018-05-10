//
//  TZMixCacheFile.h
//  TZMixTool
//
//  Created by CXY on 2018/5/4.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TZMixCacheFile : NSObject
@property (nonatomic,copy) NSString *oldClassName;//原始文件名
@property (nonatomic,copy) NSString *oldClassNameNoExtension;//不带扩展名
@property (nonatomic,copy) NSString *modifyClassNameNoExtension;//修改后的名称
@property (nonatomic,copy) NSString *path;//原始路径
@property (nonatomic,copy) NSMutableString *content;//文件内容
@property (nonatomic,assign) BOOL disableRename;//是否需要重命名

@property (nonatomic,assign,readonly) BOOL isHFile;//是否为头文件
@property (nonatomic,assign,readonly) BOOL isMFile;//是否为实现文件
@property (nonatomic,assign,readonly) BOOL  isProjectConfigFile;//是否为项目配置文件
@property (nonatomic,assign,readonly) BOOL isCategory;//是否为分类
@property (nonatomic,copy) NSString *categoryfirstName;
@property (nonatomic,copy) NSString *categoryLastName;



+(instancetype)BuildWithPath:(NSString *)filePath fileName:(NSString *)fileName;
-(void)save;
@end
