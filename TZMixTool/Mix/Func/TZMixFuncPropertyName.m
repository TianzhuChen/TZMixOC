//
//  TZMixFuncPropertyName.m
//  TZMixTool
//
//  Created by CXY on 2018/5/8.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixFuncPropertyName.h"
@interface TZMixFuncPropertyName()
{
	NSUInteger index;
}
@property (nonatomic,strong) NSArray *tempNames;
@property (nonatomic,strong) NSMutableDictionary *cachePropertyName;
@end
@implementation TZMixFuncPropertyName
-(void)start
{
	_cachePropertyName=[NSMutableDictionary new];
	_tempNames=@[@"name",@"Is",@"Sex",@"TextView",@"left",@"right",@"top",@"bottom",@"string",@"Int",@"Float",@"sun",@"page",@"hello",@"start",@"stop"];
	[self.mixManager updateLog:@"开始混淆属性"];
	index=0;
	NSString *modifiedName;
	for (TZMixCacheFile *cacheFile in self.mixManager.cacheData.allValues) {
		if(cacheFile.isHFile){//目前只修改H文件中声明的属性
			modifiedName=nil;
			for (NSString *propertyName in [self getFilePropertyNames:cacheFile]) {//替换查找到的属性
				index++;
				modifiedName=[self.cachePropertyName objectForKey:propertyName];
				if(modifiedName){//如果已经存在同名修改
					[self modifyNameInContentFile:cacheFile.content oldName:propertyName newName:modifiedName];
				}else{
					modifiedName=[self createNewName];
					[self.cachePropertyName setObject:modifiedName forKey:propertyName];
					[self modifyNameInContentFile:cacheFile.content oldName:propertyName newName:modifiedName];
					[self modifyNameInAllFile:propertyName newName:modifiedName];
				}
			}
		}
	}
	[self.mixManager updateLog:[NSString stringWithFormat:@"混淆属性完毕>>>%ld",index]];
}

-(NSArray<NSString *> *)getFilePropertyNames:(TZMixCacheFile *)cacheFile
{
	NSString *regex=[NSString stringWithFormat:@"(([^/]@property)(.*;))"];//第一步找出属性声明的
	NSError *error;
	NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
																			 options:0
																			   error:&error];
	if(error){
		NSLog(@"匹配文件出错>>%@",[error localizedDescription]);
		return nil;
	}
	NSArray<NSTextCheckingResult *> *matches = [regular matchesInString:cacheFile.content
																options:0
																  range:NSMakeRange(0, cacheFile.content.length)];
	NSMutableArray *results=[NSMutableArray new];
	__block NSString *temp1;
	[matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		temp1=[self findPropertyName:[cacheFile.content substringWithRange:obj.range]];
		if(temp1){
			[results addObject:temp1];
		}
		
	}];
	return [NSArray arrayWithArray:results];
}
-(NSString *)findPropertyName:(NSString *)string
{
	NSRange temp=[string rangeOfString:@"([^(\\s\\*)]\\w+([\\s])*;)" options:NSRegularExpressionSearch];//查找到包含;的属性
	if(temp.location==NSNotFound){
		return nil;
	}else{
		string=[string substringWithRange:temp];
//		NSLog(@"找到的属性%@",string);
		temp=[string rangeOfString:@"(.+[^\\s;])" options:NSRegularExpressionSearch];//获取到最终的属性名称
		if(temp.location!=NSNotFound){
			return [string substringWithRange:temp];
//			NSLog(@"最终属性>>>%@",[string substringWithRange:temp]);
		}else{
			return nil;
		}
		
	}
	return nil;
}
//创建一个新名称
-(NSString *)createNewName
{
	NSString *tempName=[self.mixManager createMixName:self.tempNames];
	if([self.cachePropertyName.allValues containsObject:tempName]){//如果新名称已经被创建了
		return [self createNewName];
	}else{
		return tempName;
	}
}
//替换h文件中的属性
-(void)modifyNameInContentFile:(NSMutableString *)content oldName:(NSString *)oldName newName:(NSString *)newName
{
	NSRange temp=[content rangeOfString:[NSString stringWithFormat:@"(%@([\\s])*;)",oldName] options:NSRegularExpressionSearch];//查找到包含;的属性
	if(temp.location!=NSNotFound){
		
		[content replaceCharactersInRange:temp withString:[NSString stringWithFormat:@"%@;",newName]];
	}
}
//替换m文件中的属性
-(void)modifyNameInAllFile:(NSString *)oldName newName:(NSString *)newName
{
	for (TZMixCacheFile *cacheFile in self.mixManager.cacheData.allValues) {
		if(cacheFile.isMFile){
			NSString *regex=[NSString stringWithFormat:@"[.|_|\\s|)]%@[^\\w:]",oldName];
			NSError *error;
			NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
																					 options:0
																					   error:&error];
			if(error){
				NSLog(@"匹配文件出错>>%@",[error localizedDescription]);
				return;
			}
			NSArray<NSTextCheckingResult *> *matches = [regular matchesInString:cacheFile.content
																		options:0
																		  range:NSMakeRange(0, [cacheFile.content length])];
			NSTextCheckingResult *result;
			for (NSInteger i=matches.count-1; i>=0; i--) {
				result=matches[i];
				[cacheFile.content replaceCharactersInRange:NSMakeRange(result.range.location+1, oldName.length)
												 withString:newName];
			}
//			for (NSTextCheckingResult *result in matches) {
//				NSLog(@"修改内容>>>%@---%@----%@",newName,oldName,NSStringFromRange(result.range));
//				//匹配结果肯定是前面带了一个符号
//				[cacheFile.content replaceCharactersInRange:NSMakeRange(result.range.location+1, result.range.length-1)
//												 withString:newName];
//			}
		}
	}
}
@end
