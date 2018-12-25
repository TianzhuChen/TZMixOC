//
//  TZMixConfig.h
//  TZMixTool
//
//  Created by CXY on 2018/5/6.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;
@interface TZMixConfig : NSObject
@property (nonatomic,copy) NSString *projectRoot;//项目根目录
@property (nonatomic,assign) NSInteger maxClassNameWordCount;//新类名最多由多少个单词组成
@property (nonatomic,copy) NSArray<NSString *> *ingoreFolderArray;//忽略文件目录
@property (nonatomic,copy) NSMutableArray<NSString *> *reserveFileNameArray;//保留文件名称比如main.m,只改内容不改名称
@property (nonatomic,copy) NSArray<NSString *> *classNameArray;//拼接新类名的数组
@property (nonatomic,copy) NSArray<NSString *> *modifyFileTypeArray;//修改的文件数组扩展
@property (nonatomic,assign) BOOL isMixClassName;
@property (nonatomic,assign) BOOL isMixPropertyName;
@property (nonatomic,assign) BOOL isMixImageName;
@property (nonatomic,assign) BOOL isMixFuncName;
@property (nonatomic,assign) BOOL isAddRubbishCode;
@property (nonatomic,assign) BOOL isAddClassPrefix;
@property (assign, nonatomic) BOOL isDeleteNamedColor;
-(instancetype)initWithConfig:(NSDictionary *)config;
-(void)saveToLocalFile;
@end
