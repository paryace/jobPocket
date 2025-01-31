//
//  BBTopRepDataModel.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "BBTopRepDataModel.h"
#import "BBTopItemDataModel.h"
@implementation BBTopRepDataModel
-(instancetype)init
{
    self=[super init];
    if (self) {
        self.Data=[NSMutableArray array];
    }
    return self;
}
#pragma mark 用于保持城市信息或区域信息
-(void)writeToFile:(NSString*)path
{
    NSString * savePath = [[BBTopRepDataModel getDocumentFolderByName] stringByAppendingPathComponent:path];
    NSMutableArray *writeArray=[NSMutableArray array];
    [self.Data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        BBTopItemDataModel *itemMode=(BBTopItemDataModel*)obj;
        NSData *data=[itemMode archive];
        [writeArray addObject:data];
    }];
    [writeArray writeToFile:savePath atomically:NO];
}
#pragma mark 从保存的初始化为BBTopItemDataModel
-(void)readFromFile:(NSString*)path
{
    NSString * savePath = [[BBTopRepDataModel getDocumentFolderByName] stringByAppendingPathComponent:path];
    NSArray *array=[NSArray arrayWithContentsOfFile:savePath];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSData *data=(NSData*)obj;
        [self.Data addObject:[BBTopItemDataModel unarchiveWithData:data]];
    }];
}
+(NSString *) getDocumentFolderByName
{
    NSString *foldername=@"Broadband";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([foldername length])
    {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:foldername];
    }
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileMgr fileExistsAtPath:documentsDirectory isDirectory:&isDir])
    {
        [fileMgr createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentsDirectory;
}
#pragma mark 删除目录
+(void)deleteDir
{
    NSString *path=[BBTopRepDataModel getDocumentFolderByName ];
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
}
-(void)transformWithArray:(NSArray*)array
{
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if ([obj isKindOfClass:[NSDictionary class]]) {
            BBTopItemDataModel *item=[[BBTopItemDataModel alloc] initWithDictionary:obj];
            [self.Data addObject:item];
        }
        
    }];
}
@end
