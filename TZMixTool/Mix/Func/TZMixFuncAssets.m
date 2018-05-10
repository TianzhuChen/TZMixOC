//
//  TZMixFuncAssets.m
//  TZMixTool
//
//  Created by CXY on 2018/5/5.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixFuncAssets.h"
@interface TZMixFuncAssets()
{
	NSFileManager *fm;
	NSInteger index;
}
@property (nonatomic,copy) NSArray<NSString *> *assetsExtension;
@property (nonatomic,copy) NSArray<NSString *> *nameList;
@end
@implementation TZMixFuncAssets
-(NSMutableArray<NSString *> *)xcassetsPath
{
	if(_xcassetsPath==nil)
	{
		_xcassetsPath=[NSMutableArray new];
	}
	return _xcassetsPath;
}
-(NSArray<NSString *> *)assetsExtension
{
	if(_assetsExtension==nil){
		_assetsExtension=@[@"imageset"];//,@"appiconset",@"launchimage"];
	}
	return _assetsExtension;
}
-(NSArray<NSString *> *)nameList
{
	if(_nameList==nil){
		_nameList=@[@"icon",@"user",@"pg",@"count",@"stpper",@"wait",@"portin"];
	}
	return _nameList;
}
-(void)start
{
	[self.mixManager updateLog:@"开始重命名图片"];
	if(self.xcassetsPath.count==0){
		[self.mixManager updateLog:@"没找到资源文件目录"];
		return;
	}
	fm=[NSFileManager defaultManager];
	NSArray *fileNames;
	NSString *fileName;
	NSError *error;
	for (NSString *path in self.xcassetsPath) {//遍历跟资源目录
		fileNames=[fm contentsOfDirectoryAtPath:path error:&error];
		if(error){
			[self.mixManager updateLog:[error localizedDescription]];
		}
		for (fileName in fileNames) {//遍历修改目录中的图片
			[self renameImagesetFolder:[path stringByAppendingPathComponent:fileName]];
		}
	}
	[self.mixManager updateLog:[NSString stringWithFormat:@"重命名图片结束>>%ld",index]];
}
-(void)renameImagesetFolder:(NSString *)rootPath
{
	BOOL isDirectory;
	if([fm fileExistsAtPath:rootPath isDirectory:&isDirectory] && isDirectory){//路径如果是文件夹
		if([self.assetsExtension containsObject:rootPath.pathExtension]){//如果路径包含指定的可以修改的图片文件夹
			[self renameImageset:rootPath];
		}else{//如果是文件夹递归遍历
			for (NSString *fileName in [fm contentsOfDirectoryAtPath:rootPath error:nil]) {
				[self renameImagesetFolder:[rootPath stringByAppendingPathComponent:fileName]];
			}
		}
	}
}
-(void)renameImageset:(NSString *)path
{
	NSError *error;
	NSString *jsonPath=[path stringByAppendingPathComponent:@"Contents.json"];
	NSMutableString *contentJson=[NSMutableString stringWithContentsOfFile:jsonPath
																  encoding:NSUTF8StringEncoding
																	 error:&error];
	NSString *oldName;
	NSString *newName;
	NSString *fileName;
	if(error){
		NSLog(@"文件读取错误>>%@",path);
		return;
	}else{
		for(fileName in [fm contentsOfDirectoryAtPath:path error:nil]) {
			if(![fileName.pathExtension isEqualToString:@"json"])
			{
				oldName=[fileName stringByDeletingPathExtension];
				newName=[self.mixManager createMixName:self.nameList];
				if([self regexString:oldName content:contentJson newName:newName])
				{
					[fm moveItemAtPath:[path stringByAppendingPathComponent:fileName]
								toPath:[path stringByAppendingPathComponent:[newName stringByAppendingPathExtension:fileName.pathExtension]]
								 error:&error];
					if(error){
						NSLog(@"移动文件错误>>>%@",[error localizedDescription]);
					}else{
						index++;
					}
				}
			}
		}
		[contentJson writeToFile:jsonPath
					  atomically:YES
						encoding:NSUTF8StringEncoding
						   error:&error];
		if(error){
			NSLog(@"写入Contents.json出错>>>%@",jsonPath);
		}
	}
}
//修改conent.json文件内容
-(BOOL)regexString:(NSString *)oldName content:(NSMutableString *)content newName:(NSString *)newName
{
	NSString *regex=[NSString stringWithFormat:@"\"%@\\.",oldName];
	newName=[NSString stringWithFormat:@"\"%@.",newName];
	NSError *error;
	NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
																			 options:0
																			   error:&error];
	if(error){
		NSLog(@"匹配文件出错>>%@",[error localizedDescription]);
	}
	NSInteger index;
	index=[regular replaceMatchesInString:content
								  options:0
									range:NSMakeRange(0, content.length)
							 withTemplate:newName];
	if(index>0){
		return YES;
	}
	return NO;
}
@end
