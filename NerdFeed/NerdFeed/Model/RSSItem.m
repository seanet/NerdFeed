//
//  RSSItem.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "RSSItem.h"

@implementation RSSItem
@synthesize parentParserDelegate=_parentParserDelegate;
@synthesize title=_title,link=_link,publicationDate=_publicationDate;

-(BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[RSSItem class]]){
        return NO;
    }
    
    return [[self link] isEqual:[object link]];
}

#pragma mark - xml parser delegate

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    DSLog(@"\t\t%@ found a %@ element",self,elementName);
    
    if([elementName isEqualToString:@"title"]){
        currentString=[[NSMutableString alloc]init];
        [self setTitle:currentString];
    }else if([elementName isEqualToString:@"link"]){
        currentString=[[NSMutableString alloc]init];
        [self setLink:currentString];
    }else if([elementName isEqualToString:@"pubDate"]){
        currentString =[[NSMutableString alloc]init];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"pubDate"]){
        static NSDateFormatter *dateFormatter=nil;
        if(!dateFormatter){
            dateFormatter=[[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
        }
        [self setPublicationDate:[dateFormatter dateFromString:currentString]];
    }
    
    currentString=nil;
    
    if([elementName isEqualToString:@"item"]
       ||[elementName isEqualToString:@"entry"]){
        [parser setDelegate:_parentParserDelegate];
    }
}

#pragma mark - jsonserializable delegate

-(void)readFromJSONDictionary:(NSDictionary *)dict
{
    [self setTitle:[[dict objectForKey:@"title"] objectForKey:@"label"]];
    NSArray *links=[dict objectForKey:@"link"];
    if([links count]>1){
        NSDictionary *sampleDict=[[links objectAtIndex:1] objectForKey:@"attributes"];
        self.link=[sampleDict objectForKey:@"href"];
    }
}

#pragma mark - nscoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_link forKey:@"link"];
    [aCoder encodeObject:_publicationDate forKey:@"publicationDate"];    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if(self){
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setLink:[aDecoder decodeObjectForKey:@"link"]];
        [self setPublicationDate:[aDecoder decodeObjectForKey:@"publicationDate"]];
    }
    
    return self;
}

@end
