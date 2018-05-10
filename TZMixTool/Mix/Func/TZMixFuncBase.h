//
//  TZMixFuncBase.h
//  TZMixTool
//
//  Created by CXY on 2018/5/7.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZMixManager.h"

@interface TZMixFuncBase : NSObject
@property (nonatomic,weak) TZMixManager *mixManager;
-(void)start;
@end
