//
//  TZMixFuncFunctionName.m
//  TZMixTool
//
//  Created by CXY on 2018/5/8.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixFuncFunctionName.h"

@implementation TZMixFuncFunctionName
-(void)start
{
	for (TZMixCacheFile *cacheFile in self.mixManager.cacheData.allValues) {
		if(cacheFile.isHFile){
			[self start];
			[self test:nil fors:nil];
			[self test];
		}
	}
}
-(void)test:(NSString *)temp fors:(NSString *)string
{
	
}
-(void)test{
	
}
@end
