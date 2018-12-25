//
//  TZMixDeleteNamedColor.m
//  TZMixTool
//
//  Created by CTZ on 2018/12/25.
//  Copyright © 2018 CTZ. All rights reserved.
//

#import "TZMixDeleteNamedColor.h"
@interface TZMixDeleteNamedColor()
@property (assign, nonatomic) NSUInteger colorIndex;
@property (assign, nonatomic) BOOL needSave;
@property (strong, nonatomic)  NSMutableDictionary<NSString *,DDXMLElement*> *namedColorDic;
@end
@implementation TZMixDeleteNamedColor
-(void)start
{
    [self.mixManager updateLog:@"开始删除NamedColor"];
    TZMixCacheFile *fileModel;
    self.namedColorDic=[NSMutableDictionary new];
//    NSUInteger index =0;
    //第一次遍历修改类名
    for (NSString *path in self.mixManager.cacheFilePathArray) {
        fileModel=[self.mixManager.cacheData objectForKey:path];
        DDXMLDocument  *rootNode =  [[DDXMLDocument alloc] initWithXMLString:fileModel.content options:0 error:nil];
        //先取出资源节点所有的颜色
        DDXMLElement *resourceNode=[rootNode nodesForXPath:@"//resources" error:nil].firstObject;
        NSArray<DDXMLElement *> *namedColorNodes = [resourceNode nodesForXPath:@"//namedColor" error:nil];
        //如果有用到NamedColor特性开始遍历替换
        if(namedColorNodes.count>0){
            [namedColorNodes enumerateObjectsUsingBlock:^(DDXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DDXMLElement *temp=(DDXMLElement *)[obj nextNode];
                if(temp){
                    [self.namedColorDic setObject:temp forKey:[[obj attributeForName:@"name"] stringValue]];
                }
            }];
            //获取便利节点
            NSArray<DDXMLElement *> *childNodes;
            if([path hasSuffix:@"xib"]){
                childNodes=[rootNode nodesForXPath:@"//objects" error:nil];
            }else if([path hasSuffix:@"storyboard"]){
                childNodes=[rootNode nodesForXPath:@"//scenes/scene" error:nil];
            }
//
            //查找替换颜色
            self.needSave=NO;
            [childNodes enumerateObjectsUsingBlock:^(DDXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self findColorNode:obj];
            }];
            fileModel.content=[NSMutableString stringWithString:rootNode.XMLString];
//            [resourceNode removeNamespaceForPrefix:@"namedColor"];
//            [resourceNode removeChildAtIndex:0];
//             NSLog(@"添加后颜色>>>%@",resourceNode.XMLString);
            if(self.needSave){
                 NSLog(@"////////////////文件名%@/////////////",fileModel.oldClassName);
                fileModel.isNeedSave=YES;
            }
            
        }
    }
    [self.mixManager updateLog:[NSString stringWithFormat:@"处理%ld个NamedColor",self.colorIndex]];
}
-(void)findColorNode:(DDXMLElement *)node
{
    if([node.name isEqualToString:@"color"]){//获取Color节点
        if([node attributeForName:@"name"]!=nil)
        {
            self.needSave=YES;
            self.colorIndex++;
            [self addAttributeToColor:node namedColor:[self.namedColorDic objectForKey:[node attributeForName:@"name"].stringValue]];
//            NSLog(@"使用namedColor>>>%@",node.XMLString);
        }else{
//            NSLog(@"找到的颜色>>>%@",node.XMLString);
        }
    }else{
        for (DDXMLElement *childNode in node.children) {
            [self findColorNode:childNode];
        }
    }
}
-(void)addAttributeToColor:(DDXMLElement *)colorNode namedColor:(DDXMLElement *)namedColorNode
{
    
    if(namedColorNode){
        NSLog(@"添加前颜色>>>%@",colorNode.XMLString);
        NSDictionary *allAttr=namedColorNode.attributesAsDictionary;
        [allAttr.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [colorNode addAttributeWithName:obj stringValue:[allAttr objectForKey:obj]];
        }];
        [colorNode removeAttributeForName:@"name"];
        NSLog(@"添加后颜色>>>%@",colorNode.XMLString);
    }
   
}
@end
