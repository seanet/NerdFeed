//
//  RSSChannel.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RSSChannel : NSObject<NSXMLParserDelegate,JSONSerializableDelegate,NSCoding,NSCopying>
{
    NSMutableString *currentString;
}

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *infoString;
@property (nonatomic,readonly,strong)NSMutableArray *items;

-(void)trimItemTitles;
-(void)addItemsFromChannel:(RSSChannel *)otherChannel;

@end
