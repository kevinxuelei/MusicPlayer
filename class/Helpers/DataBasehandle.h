//
//  DataBasehandle.h
//  WJL-Watercress
//
//  Created by 王剑亮 on 15/10/8.
//  Copyright (c) 2015年 wangjianliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBasehandle : NSObject
+(DataBasehandle *) sharedDataBasehandle;

//创建一个表 或者 打开已经创建的表
-(void)createtableName:(NSString *)name Model:(id)model;

//插入一个model
-(void)insertIntoTableModel:(id )model;

//删除一个 model
-(void)deleteFromTableModel:(id )model;

//取出表中全部的Model
-(NSMutableArray *)selectAllModel;

//更新表中 属性的值
-(void)updateFromAttributeName:(NSString *)attributeName Oldstring:(NSString *)oldname NewString:(NSString *)newstring;

//查找出来 属性值的model数组
-(NSMutableArray *)selectFromAttributeName:(NSString *)attributeName ValueStr:(NSString *)valueStr;

@end
