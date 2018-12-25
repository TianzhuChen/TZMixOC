//
//  TZMixFuncClassName.m
//  TZMixTool
//
//  Created by CXY on 2018/5/3.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixFuncClassName.h"
#import "JQFMDB.h"
@interface TZMixFuncClassName()
{
//	JQFMDB *db;
	NSFileManager *fm;
}
@property (nonatomic,strong) NSMutableDictionary *createdNewClassNameArray;
@end
@implementation TZMixFuncClassName
-(instancetype)init
{
	self=[super init];
	if(self){
//		db=[JQFMDB shareDatabase];
//		[db jq_createTable:@"ClassTable" dicOrModel:@{KeyOldClassName:@"TEXT", KeyNewClassName:@"TEXT"}];
	}
	return self;
}
-(void)start
{
	[self.mixManager updateLog:@"开始修改类名"];
	_createdNewClassNameArray=[NSMutableDictionary new];
	fm=[NSFileManager defaultManager];
	TZMixCacheFile *modifingModel;
	TZMixCacheFile *modifingModel1;
	
	NSUInteger index =0;
	//第一次遍历修改类名
	for (NSString *path in self.mixManager.cacheFilePathArray) {
		modifingModel=[self.mixManager.cacheData objectForKey:path];
		if(modifingModel.isCategory){//先不修改分类
			continue;
		}
		if(modifingModel.disableRename){//不需要修改类名的
			continue;
		}
		//首先查找缓存名称，比如h.m的名称一般都是一致的，xib也是一致的
		modifingModel.modifyClassNameNoExtension=[self.createdNewClassNameArray objectForKey:modifingModel.oldClassNameNoExtension];
		if(modifingModel.modifyClassNameNoExtension){//已经存在说明修改过或者不需要修改(m.h）文件
			index++;
			continue;
//			NSLog(@"修改完类名>>%ld---%@>>>%@",index,modifingModel.oldClassName,modifingModel.modifyClassNameNoExtension);
		}else{
			modifingModel.modifyClassNameNoExtension=[self createNewClassName:modifingModel.oldClassNameNoExtension];
			for (NSString *path1 in self.mixManager.cacheFilePathArray) {
				modifingModel1=[self.mixManager.cacheData objectForKey:path1];
				[self modifyClassName:modifingModel.oldClassNameNoExtension
						   modifyName:modifingModel.modifyClassNameNoExtension
							cacheFile:modifingModel1];
//				[modifingModel1 modifyClassName:modifingModel.oldClassNameNoExtension
//									 modifyName:modifingModel.modifyClassNameNoExtension];
			}
			index++;
//			NSLog(@"修改完类名>>%ld---%@>>>%@",index,modifingModel.oldClassName,modifingModel.modifyClassNameNoExtension);
		}
	}
	NSString *tempName;
	//第二次遍历修改，只改分类
	for (NSString *path in self.mixManager.cacheFilePathArray) {//遍历
		modifingModel=[self.mixManager.cacheData objectForKey:path];
		if(modifingModel.isCategory){//只修改分类
			tempName=[self.createdNewClassNameArray objectForKey:modifingModel.categoryfirstName];//根据分类的类名来取
			if(tempName){//如果存在说明分类是根据改名过的类建立的
				modifingModel.categoryfirstName=tempName;
				//要转义下+号，不然正则匹配出错
				modifingModel.modifyClassNameNoExtension=[NSString stringWithFormat:@"%@+%@",modifingModel.categoryfirstName,modifingModel.categoryLastName];
				for (NSString *path1 in self.mixManager.cacheFilePathArray) {
					modifingModel1=[self.mixManager.cacheData objectForKey:path1];
					[self modifyClassName:[modifingModel.oldClassNameNoExtension stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"]
							   modifyName:modifingModel.modifyClassNameNoExtension
								cacheFile:modifingModel1];
//					[modifingModel1 modifyClassName:[modifingModel.oldClassNameNoExtension stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"]
//										 modifyName:modifingModel.modifyClassNameNoExtension];
				}
				index++;
				tempName=nil;
			}else{//如果没有名称，说明分类是根据系统类或者第三方类修改的，暂时忽略掉
				
				continue;
			}
			
		}else{
			continue;
		}
	}

	[self.mixManager updateLog:[NSString stringWithFormat:@"修改类名结束>>>%ld",index]];
}
-(NSString *)createNewClassName:(NSString *)oldName
{
	NSString *tempName=[self.createdNewClassNameArray objectForKey:oldName];//缓存取名
	if(tempName){
		return tempName;
	}else{
		tempName=[self.mixManager createMixClassName];//生成一个随机名称
		if([self.createdNewClassNameArray.allValues containsObject:tempName]){//如果随机名称已经有了，递归重新生成
			return [self createNewClassName:oldName];
		}else{
			[self.createdNewClassNameArray setObject:tempName forKey:oldName];
			return tempName;
		}
		
	}
}
/**
 处理文件
 @param filePath 文件路径
 */
-(void)modifyFile:(NSString *)filePath fileName:(NSString *)fileName
{
	[[TZMixManager SharedManager].cacheFilePathArray addObject:filePath];
	NSLog(@"需要处理的文件>>>%@",filePath);
}
//修改替换
-(void)modifyClassName:(NSString *)oldName
			modifyName:(NSString *)modifyName
			 cacheFile:(TZMixCacheFile *)cacheFile
{
    cacheFile.isNeedSave=YES;
	if(cacheFile.isProjectConfigFile){//如果是项目文件需要特殊处理替换
		[self modifyClassNameInProejctConfigFile:oldName
									  modifyName:modifyName
									   cacheFile:cacheFile];
		return;
	}
	//	NSString *regex=[NSString stringWithFormat:@"%@%@%@",self.regexPrefix,oldName,self.regexSuffix];
	NSString *regex=[NSString stringWithFormat:@"\\b%@\\b",oldName];
	NSError *error;
	NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
																			 options:0
																			   error:&error];
	if(error){
		NSLog(@"匹配文件出错>>%@",[error localizedDescription]);
	}
	NSInteger index;
	index=[regular replaceMatchesInString:cacheFile.content
								  options:0
									range:NSMakeRange(0, cacheFile.content.length)
							 withTemplate:modifyName];
}
//修改配置文件
-(void)modifyClassNameInProejctConfigFile:(NSString *)oldName
							   modifyName:(NSString *)modifyName
								cacheFile:(TZMixCacheFile *)cacheFile
{
    cacheFile.isNeedSave=YES;
	//	if(self.isCategory){//如果是分类要对+进行转义
	//		oldName=[oldName stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
	//	}
	NSString *regex=[NSString stringWithFormat:@"\\b%@\\.",oldName];
	NSError *error;
	NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
																			 options:0
																			   error:&error];
	if(error){
		NSLog(@"匹配文件出错>>%@",[error localizedDescription]);
		return;
	}
	NSInteger index;
	index=[regular replaceMatchesInString:cacheFile.content
								  options:0
									range:NSMakeRange(0, cacheFile.content.length)
							 withTemplate:[NSString stringWithFormat:@"%@.",modifyName]];
}
@end
