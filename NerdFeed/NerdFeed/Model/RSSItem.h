//
//  RSSItem.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RSSItem : NSObject<NSXMLParserDelegate,JSONSerializableDelegate,NSCoding>
{
    NSMutableString *currentString;
}

@property (nonatomic,weak)id parentParserDelegate;

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *link;
@property (nonatomic,strong)NSDate *publicationDate;

@end
