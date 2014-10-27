//
//  RSSChannel.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "RSSChannel.h"
#import "RSSItem.h"

@implementation RSSChannel
@synthesize title=_title,infoString=_infoString,items=_items;

-(id)init
{
    self=[super init];
    if(self){
        _items=[[NSMutableArray alloc]init];
    }
    
    return self;
}

-(void)trimItemTitles
{
    NSRegularExpression *reg=[NSRegularExpression regularExpressionWithPattern:@".* :: (.*) :: .*" options:0 error:nil];
    
    for(RSSItem *item in _items){
        NSString *itemTitle=[item title];
        NSArray *results=[reg matchesInString:itemTitle options:0 range:NSMakeRange(0, [itemTitle length])];
        
        if([results count]){
            NSTextCheckingResult *result=[results objectAtIndex:0];
            DSLog(@"Match at {%ld, %ld} for %@",(long)[result range].location,(long)[result range].length,itemTitle);
            
            if([result numberOfRanges]==2){
                NSRange titleRange=[result rangeAtIndex:1];
                [item setTitle:[itemTitle substringWithRange:titleRange]];
            }
        }
    }
}

-(void)addItemsFromChannel:(RSSChannel *)otherChannel
{
    for(RSSItem *i in [otherChannel items]){
        if(![self.items containsObject:i]){
            [self.items addObject:i];
        }
    }
    
    [self.items sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
        return [[obj2 publicationDate]compare:[obj1 publicationDate]];
    }];
    
    [self setTitle:otherChannel.title];
    [self setInfoString:otherChannel.infoString];
}

#pragma mark - NSXMLParser delegate

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    DSLog(@"\t%@ found a %@ element",self,elementName);
    
    if([elementName isEqualToString:@"title"]){
        currentString=[[NSMutableString alloc]init];
        [self setTitle:currentString];
    }else if([elementName isEqualToString:@"description"]){
        currentString=[[NSMutableString alloc]init];
        [self setInfoString:currentString];
    }else if([elementName isEqualToString:@"item"]
             ||[elementName isEqualToString:@"entry"]){
        RSSItem *item=[[RSSItem alloc]init];
        [item setParentParserDelegate:self];
        [parser setDelegate:item];
        [_items addObject:item];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    currentString =nil;
    
    if([elementName isEqualToString:@"channel"]){
        [self trimItemTitles];
    }
}

#pragma mark - jsonserializable delegate

-(void)readFromJSONDictionary:(NSDictionary *)dict
{
    NSDictionary *feed=[dict objectForKey:@"feed"];
    [self setTitle:[[[feed objectForKey:@"author"] objectForKey:@"name"] objectForKey:@"label"]];
    
    NSArray *itemDictArray=[feed objectForKey:@"entry"];
    for(NSDictionary *itemDict in itemDictArray){
        RSSItem *item=[[RSSItem alloc]init];
        [item readFromJSONDictionary:itemDict];
        
        [_items addObject:item];
    }
}

#pragma mark - nscoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_items forKey:@"items"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_infoString forKey:@"infoString"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if(self){
        _items=[aDecoder decodeObjectForKey:@"items"];
        self.title=[aDecoder decodeObjectForKey:@"title"];
        self.infoString=[aDecoder decodeObjectForKey:@"infoString"];
    }
    
    return self;
}

#pragma mark - nscopying

-(id)copyWithZone:(NSZone *)zone
{
    RSSChannel *c=[[[self class]alloc]init];
    [c setTitle:self.title];
    [c setInfoString:self.infoString];
    c -> _items=[_items mutableCopy];
    
    return c;
}

@end
