//
//  SplashScene.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/11/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "SplashScene.h"
#import "MainMenuScene.h"

@implementation SplashScene
-(id)init{
  self = [super init];
  
  if (self) {
    [self addChild:[SplashLayer node]];
  }
  
  return self;
}

@end

@interface SplashLayer(Private) 
-(void)fadeAndShow:(NSMutableArray *)images;

@end

@implementation SplashLayer
-(id)init{
  self = [super init];
  if(self){
    isTouchEnabled_ = YES;
    
    NSMutableArray * splashImages = [[NSMutableArray alloc] init];
    
    CCSprite *splash1 = [CCSprite spriteWithFile:@"splash_funbox.png"];
    CCSprite *splash2 = [CCSprite spriteWithFile:@"splash_ccisland.png"];
    CCSprite *splash3 = [CCSprite spriteWithFile:@"splash_tentap.png"];
    
    splash1.position = splash2.position = splash3.position = ccp(512, 384);
    
    [self addChild:splash1];
    [self addChild:splash2];
    [self addChild:splash3];
    
    [splash2 setOpacity: 0];
    [splash3 setOpacity: 0];
    
    [splashImages addObject:splash1];
    [splashImages addObject:splash2];
    [splashImages addObject:splash3];
    
    [self fadeAndShow:splashImages];
  }
  
  return self;
}

-(void)fadeAndShow:(NSMutableArray *)images{
  if([images count]<=1)
  {
    [images release];
    [[CCDirector sharedDirector]replaceScene:[MainMenuScene node]];
  }
  else
  {
    CCSprite * actual = (CCSprite *)[images objectAtIndex:0];
    [images removeObjectAtIndex:0];
    CCSprite * next = (CCSprite *)[images objectAtIndex:0];
    
    CCAction * ease = [CCEaseElasticInOut actionWithAction:[CCMoveTo
                                                             actionWithDuration:1 position:ccp(-512, 384)]];
    [actual runAction: [CCSequence actions:
           [CCDelayTime actionWithDuration:1], 
           ease,
           [CCCallFuncN actionWithTarget:self selector:@selector(remove:)],nil]];
    [next runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:3], 
                     [CCFadeIn actionWithDuration:1],
                     [CCDelayTime actionWithDuration:1],
                     [CCCallFuncND actionWithTarget:self 
                                           selector:@selector(cFadeAndShow:data:) data:images],nil]];
  }
  
}

-(void) cFadeAndShow:(id)sender data:(void*)data{
  NSMutableArray * images = (NSMutableArray *)data;
  [self fadeAndShow:images];
}

-(void)remove:(CCSprite *)s{
  [s.parent removeChild:s cleanup:YES];
}
@end
