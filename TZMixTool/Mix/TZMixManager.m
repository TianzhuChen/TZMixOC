//
//  TZMixManager.m
//  TZMixTool
//
//  Created by CXY on 2018/5/3.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixManager.h"
#import "TZMixFuncClassName.h"
#import "TZMixFuncAssets.h"
#import "TZMixFuncRubbishCode.h"
#import "TZMixFuncPropertyName.h"

@interface TZMixManager()
{
	JQFMDB *db;
	NSFileManager *fm;
//	NSArray *ingorePacketExten;//要忽略的包
}
@property (nonatomic,copy) TZMixCompleteBlock completeBlock;
@end
@implementation TZMixManager
+(instancetype)SharedManager
{
	static dispatch_once_t onceToken;
	static TZMixManager  *_instance;
	dispatch_once(&onceToken, ^{
		_instance=[[TZMixManager alloc] init];
	});
	return _instance;
}
-(instancetype)init
{
	self=[super init];
	if(self){
		
		db=[[JQFMDB shareDatabase] initWithDBName:@"cache.db" path:[NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES) firstObject]];
		_dbPath=[db valueForKey:@"dbPath"];
		_cacheData=[NSMutableDictionary new];
		_cacheXcassetsPathArray=[NSMutableArray new];
		_cacheFilePathArray=[NSMutableArray new];
		fm=[NSFileManager defaultManager];
		_logStr=[NSMutableString new];
//		_reserveFileNameArray=[NSMutableArray new];
//		[self.reserveFileNameArray addObjectsFromArray:@[@"main.m",@"project.pbxproj"]];
		//缓存类名
	}
	return self;
}
-(void)startWithConfig:(TZMixConfig *)config completeBlock:(TZMixCompleteBlock)completeBlock
{
	self.completeBlock = completeBlock;
	_config=config;
	[self start];
}
#pragma mark - 内部功能方法
-(void)start
{
	[_cacheFilePathArray removeAllObjects];
	[_cacheData removeAllObjects];
	[_cacheXcassetsPathArray removeAllObjects];
//	_cacheReserveModelArray=[NSMutableArray new];
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		@autoreleasepool {
			[self updateLog:@">>>>>>>>Hello,阳阳>>>>>>>>"];
			[self updateLog:@"生成缓存"];
			[self cacheAllModifyFilePath:self.config.projectRoot];
			[self updateLog:[NSString stringWithFormat:@"缓存了%ld个文件",self.cacheFilePathArray.count]];
			
			if(self.config.isMixClassName){
				[[[TZMixFuncClassName alloc] init] start];
			}
			if(self.config.isMixImageName){
				TZMixFuncAssets *mixAssets=[[TZMixFuncAssets alloc] init];
				mixAssets.xcassetsPath=self.cacheXcassetsPathArray;
				[mixAssets start];
			}
			if(self.config.isAddRubbishCode){
				TZMixFuncRubbishCode *rubbishCode=[[TZMixFuncRubbishCode alloc] init];
				[rubbishCode start];
			}
			if(self.config.isMixPropertyName){
				TZMixFuncPropertyName *propertyName=[[TZMixFuncPropertyName alloc] init];
				[propertyName start];
			}
			[self saveToLocal];
			if(self.completeBlock){
				dispatch_async(dispatch_get_main_queue(), ^{
					self.completeBlock();
				});
				
			}
			
		}
	});
	
	
}
/**
 缓存目录中所有文件

 @param filePath 文件夹路径
 */
-(void)cacheAllModifyFilePath:(NSString *)filePath
{
	BOOL isDirectory;
	TZMixCacheFile *model;
	NSError *error;
	NSArray<NSString *> *folderFiles=[fm contentsOfDirectoryAtPath:filePath error:&error];
	if(error==nil){
		NSString *tempFilePath;
		for (NSString *tempFileName in folderFiles) {//遍历目录下文件
			tempFilePath=[filePath stringByAppendingPathComponent:tempFileName];
			if([fm fileExistsAtPath:tempFilePath isDirectory:&isDirectory]){//判断文件类型
				if(isDirectory){//是目录
					if([self needModifyPath:tempFilePath folderName:tempFileName])//是否需要处理
					{
						[self cacheAllModifyFilePath:tempFilePath];//递归处理目录内容
						//					NSLog(@"文件夹名称>>>%@",tempFilePath);
					}else{
						continue;
					}
				}else{//文件
					if([self needModifyFile:tempFilePath fileName:tempFileName]){//是否需要处理文件
						[self.cacheFilePathArray addObject:tempFilePath];
						model=[TZMixCacheFile BuildWithPath:tempFilePath fileName:tempFileName];
						model.disableRename=[self.config.reserveFileNameArray containsObject:tempFileName];
						[self.cacheData setObject:model forKey:tempFilePath];
						//					NSLog(@"文件名称>>>%@",tempFilePath);
					}else{//如果不需要进入下一个
						continue;
					}
				}
			}
		}
	}else{
		NSLog(@"缓存文件时出错>>>%@",[error localizedDescription]);
	}
}
-(BOOL)needModifyPath:(NSString *)filePath folderName:(NSString *)folderName
{
//	if([filePath hasSuffix:KeyProjectExten]){
//		return NO;
//	}
	if(self.config.isMixImageName && [folderName.pathExtension isEqualToString:@"xcassets"]){
		[self.cacheXcassetsPathArray addObject:filePath];
	}
	if([self.config.ingoreFolderArray containsObject:folderName])
	{
		NSLog(@"忽略的文件夹>>>%@",filePath);
		return NO;
	}
	return YES;
}
-(BOOL)needModifyFile:(NSString *)filePath fileName:(NSString *)fileName
{
	
	if([self.config.modifyFileTypeArray containsObject:filePath.pathExtension]){
		return YES;
	}
	return NO;
}
-(void)saveToLocal
{
	[self updateLog:@"开始保存文件到本地"];
	for (TZMixCacheFile *fileCache in self.cacheData.allValues) {
		[fileCache save];
	}
	[self updateLog:@"文件保存结束，混淆完毕"];
}
#pragma mark - 公开方法
-(NSString *)createMixName:(NSArray<NSString *> *)nameArray
{
	return [self _createMixName:nameArray prefixName:nil maxLength:self.config.maxClassNameWordCount];
}
-(NSString *)RandomString:(NSInteger)length
{
	NSString *temp=@"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSString *randomString=@"";
	for (int i=0; i<length; i++) {
		randomString=[randomString stringByAppendingString:[temp substringWithRange:NSMakeRange(arc4random()%temp.length, 1)]];
	}
	return randomString;
}
-(NSString *)createMixClassName
{
	return [self _createMixName:self.config.classNameArray
					 prefixName:self.modifiedClassNamePrefix
					  maxLength:self.config.maxClassNameWordCount];
}
-(void)updateLog:(NSString *)log
{
	NSLog(@"%@",log);
	[self willChangeValueForKey:@"logStr"];
	[self.logStr appendString:[log stringByAppendingString:@"\n"]];
	[self didChangeValueForKey:@"logStr"];
}
#pragma mark - 私有
-(NSString *)_createMixName:(NSArray<NSString *> *)nameArray prefixName:(NSString *)prefixName maxLength:(NSInteger)maxLength
{
	if(nameArray.count>0){
		if(prefixName==nil){
			prefixName=@"";
		}
		int maxInt=2+arc4random()%(maxLength-2);
		NSUInteger count=nameArray.count;
		for (int i=0; i<maxInt; i++) {
			prefixName=[NSString stringWithFormat:@"%@%@",prefixName,nameArray[arc4random()%count]];
		}
		return prefixName;
	}else{
		return nil;
	}
}
@end
