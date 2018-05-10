//
//  ViewController.m
//  TZMixTool
//
//  Created by CXY on 2018/5/3.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSString *temp=@"ctz+temp.h";
	NSLog(@"temp>>>>>%@",temp.pathExtension);
	mixManager=[TZMixManager SharedManager];
	[mixManager addObserver:self
				 forKeyPath:@"logStr"
					options:NSKeyValueObservingOptionNew
					context:nil];
	// Do any additional setup after loading the view.
}
- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
	
	// Update the view, if already loaded.
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	__weak TZMixManager *weakMix=mixManager;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.logTextView.string=weakMix.logStr;
	});
	
}
- (IBAction)startMixHandle:(NSButton *)sender {
	TZMixConfig *config=[[TZMixConfig alloc] init];
	
	config.projectRoot=self.projectRootTF.stringValue;
	config.isMixClassName=self.classMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isMixPropertyName=self.propertyMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isMixImageName=self.imageMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isMixFuncName=self.funcMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isAddClassPrefix=self.isClassPrefixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isAddRubbishCode=self.isAddRubbishCodeCheckBox.state==NSControlStateValueOn?YES:NO;
	config.classNameArray=[self.classNameTextView.string componentsSeparatedByString:@","];
	config.ingoreFolderArray=[self.ingoreFolderTextView.string componentsSeparatedByString:@","];
	config.modifyFileTypeArray=[self.modifyFileTypeTextView.string componentsSeparatedByString:@","];
	config.reserveFileNameArray=[NSMutableArray arrayWithArray:[self.reserveFileNameTextView.string componentsSeparatedByString:@","]];
	if(config.isAddClassPrefix){
		NSMutableArray *temp=[NSMutableArray arrayWithArray:config.classNameArray];
		mixManager.modifiedClassNamePrefix=temp.firstObject;
		[temp removeObjectAtIndex:0];
		config.classNameArray=[NSArray arrayWithArray:temp];
	}
	self.startButton.enabled=NO;
	__weak ViewController *_weakSelf=self;
	[mixManager startWithConfig:config completeBlock:^{
		_weakSelf.startButton.enabled=YES;
	}];
	
	
	//	self.dbPathLabel.stringValue=mixManager.dbPath;
}
- (IBAction)openCacheFinder:(NSButton *)sender {
	//	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self.dbPathLabel.stringValue stringByDeletingLastPathComponent]]];
	[[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:[mixManager.dbPath stringByDeletingLastPathComponent]];
	//	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL URLWithString:self.dbPathLabel.stringValue]]];
}
- (IBAction)saveConfigHandle:(NSButton *)sender {
	TZMixConfig *config=[[TZMixConfig alloc] init];
	
	config.projectRoot=self.projectRootTF.stringValue;
	config.isMixClassName=self.classMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isMixPropertyName=self.propertyMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isMixImageName=self.imageMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isMixFuncName=self.funcMixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isAddClassPrefix=self.isClassPrefixCheckBox.state==NSControlStateValueOn?YES:NO;
	config.isAddRubbishCode=self.isAddRubbishCodeCheckBox.state==NSControlStateValueOn?YES:NO;
	config.classNameArray=[self.classNameTextView.string componentsSeparatedByString:@","];
	config.ingoreFolderArray=[self.ingoreFolderTextView.string componentsSeparatedByString:@","];
	config.modifyFileTypeArray=[self.modifyFileTypeTextView.string componentsSeparatedByString:@","];
	config.reserveFileNameArray=[NSMutableArray arrayWithArray:[self.reserveFileNameTextView.string componentsSeparatedByString:@","]];
	[config saveToLocalFile];
}
- (IBAction)openConfigHandle:(NSButton *)sender {
	
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];  //是否能选择文件file
	[openPanel setCanChooseDirectories:NO];  //是否能打开文件夹
	[openPanel setAllowsMultipleSelection:NO];  //是否允许多选file
	[openPanel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse result) {
		if(result==NSModalResponseOK){
			NSDictionary *configDic=[NSDictionary dictionaryWithContentsOfFile:openPanel.URL.path];
			if(configDic==nil){
				[[TZMixManager SharedManager] updateLog:@"配置文件加载错误"];
			}else{
				[self loadFromConfir:configDic];
				
			}
//			NSLog(@"加载的本地配置文件>>%@",configDic);
		}
	}];

}

-(void)loadFromConfir:(NSDictionary *)dic
{
	TZMixConfig *config=[[TZMixConfig alloc] initWithConfig:dic];
	self.projectRootTF.placeholderString=@"因为权限问题，请自行拖入路径";
	self.classMixCheckBox.state=config.isMixClassName?NSControlStateValueOn:NSControlStateValueOff;
	self.propertyMixCheckBox.state=config.isMixPropertyName?NSControlStateValueOn:NSControlStateValueOff;
	self.imageMixCheckBox.state=config.isMixImageName?NSControlStateValueOn:NSControlStateValueOff;
	self.funcMixCheckBox.state=config.isMixFuncName?NSControlStateValueOn:NSControlStateValueOff;
	self.isClassPrefixCheckBox.state=config.isAddClassPrefix?NSControlStateValueOn:NSControlStateValueOff;
	self.isAddRubbishCodeCheckBox.state=config.isAddRubbishCode?NSControlStateValueOn:NSControlStateValueOff;
	self.classNameTextView.string=[config.classNameArray componentsJoinedByString:@","];
	self.ingoreFolderTextView.string=[config.ingoreFolderArray componentsJoinedByString:@","];
	self.modifyFileTypeTextView.string=[config.modifyFileTypeArray componentsJoinedByString:@","];
	self.reserveFileNameTextView.string=[config.reserveFileNameArray componentsJoinedByString:@","];
}

@end
