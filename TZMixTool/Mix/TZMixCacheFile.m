//
//  TZMixCacheFile.m
//  TZMixTool
//
//  Created by CXY on 2018/5/4.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "TZMixCacheFile.h"
#import "TZMixManager.h"
@interface TZMixCacheFile()
{

}
@property (nonatomic,copy) NSString *regexSuffix;
@property (nonatomic,copy) NSString *regexPrefix;
@property (nonatomic,copy) NSString *newPath;
@end
@implementation TZMixCacheFile
//@synthesize oldClassNameNoExtensionn=_oldClassNameNoExtensionn;
+(instancetype)BuildWithPath:(NSString *)filePath fileName:(NSString *)fileName
{
	TZMixCacheFile *model=[[TZMixCacheFile alloc] init];
	model.path=filePath;
	model.oldClassName=fileName;//[fileName stringByDeletingPathExtension];
	return model;
}
-(void)setOldClassName:(NSString *)oldClassName
{
	_oldClassName=oldClassName;
	if([_oldClassName containsString:@"+"]){
		_isCategory=YES;
		NSArray *temp=[self.oldClassNameNoExtension componentsSeparatedByString:@"+"];
		_categoryfirstName=[temp firstObject];
		_categoryLastName=[temp lastObject];
	}
	if([_path.pathExtension isEqualToString:@"h"]){
		_isHFile=YES;
	}
	if([_path.pathExtension isEqualToString:@"m"]){
		_isMFile=YES;
	}
	if([oldClassName isEqualToString:KeyProjectFileName])
	{
		_isProjectConfigFile=YES;
	}
}
-(NSString *)oldClassNameNoExtension
{
	if(_oldClassNameNoExtension==nil)
	{
		_oldClassNameNoExtension=[self.oldClassName stringByDeletingPathExtension];
	}
	return _oldClassNameNoExtension;
}
-(NSMutableString *)content
{
	if(_content==nil){
		NSError *error;
		_content=[NSMutableString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:&error];
		if(error){
			NSLog(@"读取文件出错>>>%@",self.path);
		}
	}
	return _content;
}
-(NSString *)newPath
{
	if(_newPath==nil){
		_newPath=[self.path stringByDeletingLastPathComponent];
		if(self.isCategory){
			self.modifyClassNameNoExtension=[NSString stringWithFormat:@"%@+%@",self.categoryfirstName,self.categoryLastName];
		}
		if(self.modifyClassNameNoExtension){
			_newPath=[_newPath stringByAppendingPathComponent:self.modifyClassNameNoExtension];
			_newPath=[_newPath stringByAppendingPathExtension:self.path.pathExtension];
		}else{
			_newPath=self.path;
		}
	}
	return _newPath;
}
-(void)save
{
	if(_content && self.isNeedSave){
		NSError *error;
//		NSLog(@"写入文件路径>>>%@",[self newPath]);
		[_content writeToFile:self.newPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
		if(error){
			NSLog(@"文件写入出错>>>%@--%@",self.path,[self newPath]);
		}else{
			if([self.newPath isEqualToString:self.path]==NO){//如果路径改变，需要删除旧文件
				[[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
			}
			
		}
	}
}
@end
