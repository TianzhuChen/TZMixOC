//
//  TZMixRubbishCode.m
//  TZMixTool
//
//  Created by CXY on 2018/5/7.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixFuncRubbishCode.h"
@interface TZMixFuncRubbishCode()
@property (nonatomic,copy) NSString *funcCodePrefix;
@property (nonatomic,copy) NSArray *tempNames;
@end
@implementation TZMixFuncRubbishCode
-(void)start
{
	[self.mixManager updateLog:@"开始加入垃圾代码"];
	_tempNames=@[@"temp",@"handle",@"Click",@"Button",@"Inner",@"Fetch"];
	self.funcCodePrefix=[NSString stringWithFormat:@"%@_",[self.mixManager RandomString:2]];
	for (TZMixCacheFile *cacheFile in self.mixManager.cacheData.allValues) {
		if(cacheFile.isMFile){
			[self insertRubbishCode:cacheFile];
		}
	}
	[self.mixManager updateLog:@"结束加入垃圾代码"];
}
-(void)insertRubbishCode:(TZMixCacheFile *)cacheFile
{
	//垃圾代码
	NSString *temp=[NSString stringWithFormat:kFuncFileTemplate,[self.mixManager createMixName:self.tempNames]];
	
	NSString *regex=[NSString stringWithFormat:@"\b@end"];
	NSError *error;
	NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
																			 options:0
																			   error:&error];
	if(error){
		NSLog(@"匹配文件出错>>%@",[error localizedDescription]);
		return;
	}
	NSArray *matches = [regular matchesInString:cacheFile.content
										options:0
										  range:NSMakeRange(0, [cacheFile.content length])];
	if(matches.count>0){
		NSTextCheckingResult *match=matches.lastObject;
		[cacheFile.content replaceCharactersInRange:match.range
									withString:[NSString stringWithFormat:@"%@\n@end",temp]];
	}
//	[cacheFile insertRubbishCodeFunc:temp];
}
static NSString *const kFuncFileTemplate =@"-(void)%@{\n\
\tNSArray *temp=@[@1,@2,@3,@4,@5];\n\
\tfor (NSNumber *indx in temp) {\n\
\t}\n\
}";
static NSString *const kHClassFileTemplate = @"\
%@\n\
@interface %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kMClassFileTemplate = @"\
#import \"%@+%@.h\"\n\
@implementation %@ (%@)\n\
%@\n\
@end\n";
@end
