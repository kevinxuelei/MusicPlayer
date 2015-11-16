//
//  DataBasehandle.m
//  WJL-Watercress
//
//  Created by 王剑亮 on 15/10/8.
//  Copyright (c) 2015年 wangjianliang. All rights reserved.
//

#import "DataBasehandle.h"
#import <objc/runtime.h>
#import <sqlite3.h>
#define MyLog(...)  NSLog(__VA_ARGS__)
//http://www.sjsjw.com/kf_mobile/article/4_17043_17742.asp


@interface DataBasehandle ()
{
    id _saveModel;
}
@property (nonatomic, copy)NSString *tabelename;
@property (nonatomic, copy)NSDictionary *dic;

@end

@implementation DataBasehandle


/* 获取对象的所有属性和属性内容 */
//这个方法 返回的是一个大字典 里边放着所有不为空 的属性和他们的值 属性是Key 值 是 Value
- (NSDictionary *)getAllPropertiesAndVaulesModel:(id)model
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [model valueForKey:(NSString *)propertyName];
        
        /*下面注释的这条语句是这个函数 最开始的语句 目的获取值不为空的属性 我修改之后就可以获取model全部属
         性当然model 属性必须全部写成NSString 类型的 不管实际的类型是什么！*/
         //if (propertyValue) [props setObject:propertyValue forKey:propertyName];
        
        //这样做 就可以获取model对象的全部属性！！！！ 下面的代码是我修改的！
        if (propertyValue == nil) {
            
            [props setObject:@"nil" forKey:propertyName];
        }else
        {
          [props setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return props;
}


static DataBasehandle * shareDataManager = nil;
//这样可以防止多进程的访问 GCD 写法！！！！！
+(DataBasehandle *) sharedDataBasehandle
{
    static dispatch_once_t once;
    
    dispatch_once(&once
                  
                  , ^{
                      
                      if (shareDataManager == nil)
                      {
                          shareDataManager = [ [ DataBasehandle alloc ] init ];
                      }
                      
                  });
    return shareDataManager;
}

static sqlite3 *db = nil;

-(void)openDB
{
    //已经打开完了之后 就不需要再打开了
    if(db != nil)return;
    
    //获取沙河路径 拼接一个文件的名字
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",@"Mysqlite.sqlite"]];
    
    NSLog(@"%@",path);
    //打开数据库 初始化数据库了 已经 静态区不为nil了
    int result = sqlite3_open(path.UTF8String, &db);
    
    if(result == SQLITE_OK)
    {
        //打开成功！
        MyLog(@"打开成功");
    }else
    {
        MyLog(@"打开失败");
    }
    
}

-(void)closeDB
{
    int result = sqlite3_close(db);
    
    if (result == SQLITE_OK) {
        MyLog(@"关闭成功");
    }else
    {
        
        MyLog(@"关闭失败");
    }
    
}

//根据表的名字 和 运行时的model对象 创建一个表！
-(void)createtableName:(NSString *)name Model:(id)model
{
    //省略了打开数据库的步骤
    [shareDataManager openDB];
    //这里创建一个新的 以查询的时候下边使用
    _saveModel = [[[model class] alloc] init];
    //根据模型拼接字符串
    NSDictionary *dicstart = [self getAllPropertiesAndVaulesModel:model];
    //这里 必须这样操作一下 变成不可变的字典要不然 遍历的时候 表属性的顺序对应不上！
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:dicstart];
    self.dic = dic;
    self.tabelename = name;
    NSMutableString *str = [NSMutableString string];
    
    for (id obj in [dic allKeys] )
    {
      [str appendFormat:@" %@ text,",obj];
    }
    
    NSString *str1 = [str substringToIndex:str.length-1];
    
    //创建表的SQL语句 CREATE TABLE + 表名（字段 类型 ，...,字段 类型）
    NSString *createStr = [NSString stringWithFormat:@"CREATE TABLE  IF NOT EXISTS  %@(%@)",name,str1];
    MyLog(@"createStr === %@",createStr );
    

    //第一个参数：在那个数据库里边操作
    //第二个参数：代表要去执行那一条SQL 语句
    //第三个参数：代表那个回调函数
    //第四个参数：回调的一些参数
    //第五个参数：错误信息
    
    char *error = NULL;
    int result = sqlite3_exec(db, createStr.UTF8String, NULL, NULL, &error);
    
    printf("massage = %s",error);
    
    if(result == SQLITE_OK)
    {
        MyLog(@"创表成功");
    }else
    {
        MyLog(@"创表失败");
    }
    
}


//根据当前创建的表的名字 和运行时model对象 把model对象写入数据库
-(void)insertIntoTableModel:(id)model
{

    NSDictionary *dicstart = [self getAllPropertiesAndVaulesModel:model];
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:dicstart];
    NSString *name = self.tabelename;
    NSMutableString *strkey = [NSMutableString string];
    NSMutableString *strvalue = [NSMutableString string];
    for (id obj in [dic allKeys] )
    {
        [strkey appendFormat:@" %@,",obj];
        [strvalue appendFormat:@" '%@',",[dic objectForKey:obj]];
    }
    NSString *strkey1 = [strkey substringToIndex:strkey.length-1];
    NSString *strvalue1 = [strvalue substringToIndex:strvalue.length-1];
    
    //插入语句
    NSString *insertStr = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)",name,strkey1,strvalue1];
    //第一个参数：在那个数据库里边操作
    //第二个参数：代表要去执行那一条SQL 语句
    //第三个参数：代表那个回调函数
    //第四个参数：回调的一些参数
    //第五个参数：错误信息
    NSLog(@"%@",strkey1);
    char *message = NULL;
    int result = sqlite3_exec(db, insertStr.UTF8String, NULL, NULL, &message);
    
    printf("massage ======= %s",message);
    if(result == SQLITE_OK)
    {
        MyLog(@"插入成功");
    }else
    {
        MyLog(@"插入失败");
    }
    
}



//根据当前的表的名字和运行时model对象  删除 model对象所对应的 一条数据！
-(void)deleteFromTableModel:(id )model
{

    
    NSDictionary *dicstart = [self getAllPropertiesAndVaulesModel:model];
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:dicstart];

    NSString *name = self.tabelename;
    NSMutableString *strkey = [NSMutableString string];
    for (id obj in [dic allKeys] )
    {
        if ([ [dic objectForKey:obj ] isKindOfClass:[NSNumber class]] || [ [dic objectForKey:obj ] isKindOfClass:[NSString class]]   )
        {
            
            [strkey appendFormat:@" %@ = '%@' and",obj,[dic objectForKey:obj]];
        }
    }
    
    //去掉最后 四个字符
    NSString *strNew = [strkey substringToIndex:strkey.length-4];

    NSString *deleteStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",name,strNew];

    char *message = NULL;
    int result = sqlite3_exec(db, deleteStr.UTF8String, NULL, NULL, &message);
    printf("%s",message);
    if(result == SQLITE_OK)
    {
        MyLog(@"删除成功");
    }else
    {
        MyLog(@"删除失败");
    }
}

//根据 运行时的model对象 和表的名字 获取所有的 model对象数组
-(NSMutableArray *)selectAllModel
{
    
    NSMutableArray  *dataArray = nil;
    //根据模型拼接字符串
    NSDictionary *adddic = self.dic;
    NSString *name = self.tabelename;
    // 查询SQL 语句
    // SELECT * FROM + 表名
    NSString *selectStr = [NSString stringWithFormat:@"SELECT * FROM %@",name];

    sqlite3_stmt *stmt = nil;

    int result = sqlite3_prepare(db, selectStr.UTF8String, -1, &stmt, NULL);

    if (result == SQLITE_OK)
    {
        //定义一个泛型 的指针 在下面会初始化这个泛型具体是什么类型的！不用担心！！！！
        id Model;
        //初始化数组
        dataArray = [NSMutableArray array ];
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            //这里做的 工作最重要 要不然保存的模型 你是没办法拿到值的！！！！
            //这里根据runtime运行时 创建运行时的对象 这样就可以面对所有的对象！！！！ 哈哈哈！
           Model = [[ [_saveModel class] alloc] init];
            
            //记录 表一条数据的位置每次循环的时候 增加！！！！！
            int i = 0;
            for (NSString *key in [adddic allKeys])
            {
                
                if ([[adddic objectForKey:key] isKindOfClass:[NSString class]] || [[adddic objectForKey:key] isKindOfClass:[NSNumber class]]) {
                  
                    if ([[adddic objectForKey:key] isKindOfClass:[NSString class]])
                    {
                        
                        //这里注意一下可能是 NULL 空的 之后处理一下 避免KVC crash
                        if ((const char *)sqlite3_column_text(stmt, i) == NULL) {
                            [Model setValue:@" " forKey:key];
                        }else
                        {
                            NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                            [Model setValue:string forKey:key];
                        }

                    } else
                    {
                        NSInteger index = sqlite3_column_int(stmt, i);
                        //这里不用担心 一定能
                        NSString *string = [NSString stringWithFormat:@"%ld", (long)index];
                        [Model setValue:string forKey:key];
                    }
                    
                    i++;
                }
            }
            
            [dataArray addObject:Model];
                
          }
      
        
        
    }
    //释放伴随指针
    sqlite3_finalize(stmt);
    
    return dataArray;
}

//这里留着 给所有人去做 或者以后有需要我自己去做就可以了 哈哈！！！！！！  

-(void)updateFromAttributeName:(NSString *)attributeName Oldstring:(NSString *)oldname NewString:(NSString *)newstring
{

    //UPDATE `Demo_Table` SET `demo_name` = 'yangyang' WHERE `demo_id`=1;
    //修改语句

    NSString *updateStr = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ ='%@'",self.tabelename,attributeName,newstring,attributeName,oldname];

    int result2 = sqlite3_exec(db, updateStr.UTF8String, NULL, NULL, NULL);

    if(result2 == SQLITE_OK)
    {
        NSLog(@"修改成功");
    }else
    {
        NSLog(@"修改失败");
    }
}


-(NSMutableArray *)selectFromAttributeName:(NSString *)attributeName ValueStr:(NSString *)valueStr
{
    // 条件查询SQL 语句
    // SELECT * FROM + 表名 WHERE + 条件 + ？
    //根据模型拼接字符串
    NSDictionary *adddic = self.dic;
    
    NSString *selectStr = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ = ?",self.tabelename,attributeName];

    NSMutableArray  *dataArray = [NSMutableArray array ] ;

    sqlite3_stmt *stmt = nil;

    int result = sqlite3_prepare(db, selectStr.UTF8String, -1, &stmt, NULL);

    if (result == SQLITE_OK) {

        //填充 查询语句的问号
        sqlite3_bind_text(stmt, 1, valueStr.UTF8String, -1, NULL);

        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            id  model = [[[_saveModel class] alloc] init];
            //记录 表一条数据的位置每次循环的时候 增加！！！！！
            int i = 0;
            for (NSString *key in [adddic allKeys])
            {
                
                if ([[adddic objectForKey:key] isKindOfClass:[NSString class]] || [[adddic objectForKey:key] isKindOfClass:[NSNumber class]]) {
                    
                    if ([[adddic objectForKey:key] isKindOfClass:[NSString class]])
                    {
                        
                        //这里注意一下可能是 NULL 空的 之后处理一下 避免KVC crash
                        if ((const char *)sqlite3_column_text(stmt, i) == NULL) {
                            [model setValue:@" " forKey:key];
                        }else
                        {
                            NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                            [model setValue:string forKey:key];
                        }
                        
                    } else
                    {
                        NSInteger index = sqlite3_column_int(stmt, i);
                        //这里不用担心 一定能
                        NSString *string = [NSString stringWithFormat:@"%ld", (long)index];
                        [model setValue:string forKey:key];
                    }
                    
                    i++;
                }
            }

            
            [dataArray addObject:model];


        }
    }

    //释放伴随指针
    sqlite3_finalize(stmt);

    for (id model in dataArray) {

        NSLog(@"model ===== %@",model);
    }
    
    return dataArray;
    
    
}


@end


