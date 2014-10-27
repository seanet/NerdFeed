//
//  JSONSerializable.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-9-1.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONSerializableDelegate <NSObject>

-(void)readFromJSONDictionary:(NSDictionary *)dict;

@end
