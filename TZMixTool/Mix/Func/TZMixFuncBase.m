//
//  TZMixFuncBase.m
//  TZMixTool
//
//  Created by CXY on 2018/5/7.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixFuncBase.h"

@implementation TZMixFuncBase
-(TZMixManager *)mixManager
{
	if(_mixManager==nil){
		_mixManager=[TZMixManager SharedManager];
	}
	return _mixManager;
}
-(void)start{}
@end
