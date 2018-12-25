//
//  ViewController.h
//  TZMixTool
//
//  Created by CXY on 2018/5/3.
//  Copyright © 2018年 CTZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "TZMixManager.h"
@interface ViewController : NSViewController
{
	TZMixManager *mixManager;
}
@property (weak) IBOutlet NSTextField *projectRootTF;
@property (unsafe_unretained) IBOutlet NSTextView *classNameTextView;
@property (unsafe_unretained) IBOutlet NSTextView *ingoreFolderTextView;
@property (unsafe_unretained) IBOutlet NSTextView *modifyFileTypeTextView;
@property (unsafe_unretained) IBOutlet NSTextView *reserveFileNameTextView;

@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@property (weak) IBOutlet NSButton *propertyMixCheckBox;
@property (weak) IBOutlet NSButton *classMixCheckBox;
@property (weak) IBOutlet NSButton *imageMixCheckBox;
@property (weak) IBOutlet NSButton *funcMixCheckBox;
@property (weak) IBOutlet NSButton *isClassPrefixCheckBox;
@property (weak) IBOutlet NSButton *isReverseIngoreCheckBox;
@property (weak) IBOutlet NSButton *isAddRubbishCodeCheckBox;
@property (weak) IBOutlet NSButton *isDeleteNamedColorCheckBox;

@property (weak) IBOutlet NSButton *startButton;


@end

