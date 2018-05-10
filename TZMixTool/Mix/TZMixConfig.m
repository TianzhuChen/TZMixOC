//
//  TZMixConfig.m
//  TZMixTool
//
//  Created by CXY on 2018/5/6.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixConfig.h"
#import "TZMixManager.h"

#define KeyConfig_projectRoot @"项目根目录"
#define KeyConfig_maxClassNameWordCount @"混淆后类名单词长度"
#define KeyConfig_classNameArray @"类名混淆用单词池"
#define KeyConfig_ingoreFolderArray @"要忽略的文件夹"
#define KeyConfig_reserveFileNameArray @"要保留的文件名字"
#define KeyConfig_modifyFileTypeArray @"要修改文件类型的扩展名"
#define KeyConfig_isMixFuncName @"是否要混淆方法名"
#define KeyConfig_isMixClassName @"是否混淆类名"
#define KeyConfig_isMixImageName @"是否混淆图片名"
#define KeyConfig_isMixPropertyName @"是否混淆属性名"
#define KeyConfig_isAddClassPrefix @"是否添加类前缀"
#define KeyConfig_isAddRubbishCode @"是否添加垃圾代码"

@implementation TZMixConfig
-(instancetype)initWithConfig:(NSDictionary *)config
{
	self=[super init];
	if(self){
		_projectRoot=[config objectForKey:KeyConfig_projectRoot];
		_maxClassNameWordCount=[[config objectForKey:KeyConfig_maxClassNameWordCount] integerValue];
		_classNameArray=[config objectForKey:KeyConfig_classNameArray];
		_ingoreFolderArray=[config objectForKey:KeyConfig_ingoreFolderArray];
		_reserveFileNameArray=[config objectForKey:KeyConfig_reserveFileNameArray];
		_modifyFileTypeArray=[config objectForKey:KeyConfig_modifyFileTypeArray];
		_isMixFuncName=[[config objectForKey:KeyConfig_isMixFuncName] boolValue];
		_isMixClassName=[[config objectForKey:KeyConfig_isMixClassName] boolValue];
		_isMixImageName=[[config objectForKey:KeyConfig_isMixImageName] boolValue];
		_isMixPropertyName=[[config objectForKey:KeyConfig_isMixPropertyName] boolValue];
		_isAddClassPrefix=[[config objectForKey:KeyConfig_isAddClassPrefix] boolValue];
		_isAddRubbishCode=[[config objectForKey:KeyConfig_isAddRubbishCode] boolValue];
		[[TZMixManager SharedManager] updateLog:@"配置文件加载成功"];
	}
	return self;
}
-(NSInteger)maxClassNameWordCount
{
	if(_maxClassNameWordCount==0){
		_maxClassNameWordCount=5;
	}
	return _maxClassNameWordCount;
}
-(void)saveToLocalFile
{
	[self isMixFuncName];
	NSSavePanel *savePanel=[NSSavePanel savePanel];
	savePanel.title=@"保存配置到本地文件";
	if(self.projectRoot.length>0){
		[savePanel setNameFieldStringValue:[self.projectRoot.lastPathComponent stringByDeletingPathExtension]];
	}else{
		[savePanel setNameFieldStringValue:@"MixConfig"];
	}
	
	[savePanel setAllowedFileTypes:@[@"plist"]];
	[savePanel setExtensionHidden:YES];
	[savePanel setCanCreateDirectories:YES];
	[savePanel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse result) {
		if(result==NSModalResponseOK){
			NSString *path=[[savePanel URL] path];
			NSMutableDictionary *configDic=[NSMutableDictionary new];
			[configDic setObject:self.projectRoot forKey:KeyConfig_projectRoot];
			[configDic setObject:@(self.maxClassNameWordCount) forKey:KeyConfig_maxClassNameWordCount];
			[configDic setObject:self.classNameArray forKey:KeyConfig_classNameArray];
			[configDic setObject:self.ingoreFolderArray forKey:KeyConfig_ingoreFolderArray];
			[configDic setObject:self.reserveFileNameArray forKey:KeyConfig_reserveFileNameArray];
			[configDic setObject:self.modifyFileTypeArray forKey:KeyConfig_modifyFileTypeArray];
			[configDic setObject:@(self.isMixFuncName) forKey:KeyConfig_isMixFuncName];
			[configDic setObject:@(self.isMixClassName) forKey:KeyConfig_isMixClassName];
			[configDic setObject:@(self.isMixImageName) forKey:KeyConfig_isMixImageName];
			[configDic setObject:@(self.isMixPropertyName) forKey:KeyConfig_isMixPropertyName];
			[configDic setObject:@(self.isAddClassPrefix) forKey:KeyConfig_isAddClassPrefix];
			[configDic setObject:@(self.isAddRubbishCode) forKey:KeyConfig_isAddRubbishCode];
			[configDic writeToFile:path atomically:YES];
			[[TZMixManager SharedManager] updateLog:@"配置保存成功"];
		}
	}];
	
}
@end
