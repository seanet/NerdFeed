//
//  PercentView.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-9-3.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "PercentView.h"

@implementation PercentView
@synthesize percent=_percent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 80, 80)];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        [self.layer setCornerRadius:40];
        [self.layer setBackgroundColor:[[UIColor colorWithWhite:0.6 alpha:0.95] CGColor]];
        
        spinLayer=[[CAShapeLayer alloc]init];
        [spinLayer setBounds:self.bounds];
        [spinLayer setPosition:self.center];
        [spinLayer setFillColor:nil];
        [spinLayer setLineCap:kCALineCapRound];
        
        NSUInteger spinWidth=7;
        
        spinLayer.path=[[UIBezierPath bezierPathWithArcCenter:self.center radius:(self.bounds.size.width-spinWidth)/2.0 startAngle:0 endAngle:M_PI*0.4 clockwise:YES] CGPath];
        spinLayer.lineWidth=spinWidth;
        spinLayer.strokeColor=[[UIColor colorWithRed:176/255.0 green:224/255.0 blue:230/255.0 alpha:0.9]CGColor];
        
        [self.layer addSublayer:spinLayer];
        
        [self spinAnimation];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(spinAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)spinAnimation
{
    if(!spinAnimation){
        spinAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [spinAnimation setToValue:[NSNumber numberWithFloat:M_PI*INTMAX_MAX]];
        [spinAnimation setDuration:INTMAX_MAX/1.2];
    }
    
    [spinLayer addAnimation:spinAnimation forKey:@"spinAnimation"];
}

-(void)setPercent:(NSInteger)percent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _percent=percent;
        [self setNeedsDisplay];
    });
}

-(void)drawRect:(CGRect)rect
{
    NSString *percentText;
    UIFont *font;
    
    if(!_percent){
        percentText=@"请稍等";
        font=[UIFont boldSystemFontOfSize:18];
    }else{
        percentText=[[NSString stringWithFormat:@"%d",(int)_percent]stringByAppendingString:@"%"];
        font=[UIFont boldSystemFontOfSize:20];
    }
    
    NSDictionary *attrDict=[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    
    CGRect textRect=[percentText boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
    
    textRect.origin.x=(self.bounds.size.width-textRect.size.width)/2.0;
    textRect.origin.y=(self.bounds.size.height-textRect.size.height)/2.0;
    
    [percentText drawInRect:textRect withAttributes:attrDict];
}

@end
