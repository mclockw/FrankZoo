//
//  ResultLayer.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/11/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ResultLayer.h"
#import "FZGameLogic.h"
#import "FZPlayer.h"


@interface ResultLayer(Private)

@end

@implementation ResultLayer
@synthesize delegate_;

- (void)dealloc{
  if (menu_) {
    [menu_ release];
  }
  if (lableArray_) {
    [lableArray_ removeAllObjects];
    [lableArray_ release];
  }
  
  [super dealloc];
}

- (id)init{
  [super init];
  if (self) {
    CGSize s;
    s.width = 800; s.height = 600;
    [self setContentSize:s];
    
    //BG
    CCSprite * bg = [[CCSprite alloc] initWithFile:@"ResultLayerBg.png"];    
    [self addChild:bg];
    
    //Title
    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Result" 
                                     fontName:@"Arial" 
                                     fontSize:52];
    [title setColor:ccBLACK];
    title.position = ccp(0, 250);
    [self addChild:title];
    
    //menu
    CCLabelTTF *okLable = [CCLabelTTF labelWithString:@"OK" fontName:@"Arial" fontSize:26];
    CCMenuItem *ok = [CCMenuItemLabel itemWithLabel:okLable
                                               target:self
                                             selector:@selector(okButtonClick:)];
    menu_ = [CCMenu menuWithItems:ok, nil];
    [self addChild: menu_];
    menu_.position = ccp(250, -250);
    menu_.isTouchEnabled = NO;
    
    //lable array
    CCLabelTTF *row0 = [CCLabelTTF labelWithString:@"Name\t round score\t total score" 
                                    fontName:@"Arial" 
                                    fontSize:22];
    row0.position = ccp(0,130);
    [row0 setColor:ccBLACK];
    [self addChild:row0];
    
    lableArray_ = [[NSMutableArray alloc] initWithCapacity: 8];
    CGPoint point = ccp(0,100);
    for (int i=0; i<8; i++) {
      CCLabelTTF *row = [CCLabelTTF labelWithString:@"" 
                                      fontName:@"Arial" 
                                      fontSize:20];
      row.position = point;
      [lableArray_ addObject:row];
      [self addChild:row];
      
      point.y -= 23;
    }
  }
  return self;
}

static int roundScoreCompareFun(id obj1, id obj2, void *context){
  FZPlayer *p1 = (FZPlayer*)obj1;
  FZPlayer *p2 = (FZPlayer*)obj2;
  
  return p1.roundScore_ <= p2.roundScore_;
}

static int gameScoreCompareFun(id obj1, id obj2, void *context){
  FZPlayer *p1 = (FZPlayer*)obj1;
  FZPlayer *p2 = (FZPlayer*)obj2;
  
  return p1.gameScore_ > p2.gameScore_;
}

- (void)drawRoundResult:(FZGameLogic*)gamelogic{
  //copy array from gamelogic array
  NSMutableArray * players = [[NSMutableArray alloc] initWithArray: gamelogic.playerArray_];
  
  //sort array
  [players sortUsingFunction:roundScoreCompareFun context:nil];

  //draw score
  for (int i= 0; i < [players count]; i++) {
    FZPlayer *player = [players objectAtIndex:i];
    NSString *str = [[NSString alloc] initWithFormat:@"%@\t %d\t %d", 
                    player.playerName_, player.roundScore_, player.gameScore_];
    CCLabelTTF *label = [lableArray_ objectAtIndex:i];
    if (player.playerControlType_ == FZPlayer_ControlType_LocalPlayer) {
      [label setColor:ccRED];
    }else {
      [label setColor:ccBLACK];
    }

    [label setString:str];
    [str release];
  }
  
  //release
  [players release];
}

- (void)drawGameResult:(FZGameLogic*)gamelogic{
  //copy array from gamelogic array
  NSMutableArray * players = [[NSMutableArray alloc] initWithArray: gamelogic.playerArray_];
  
  //sort array
  [players sortUsingFunction:gameScoreCompareFun context:nil];
  
  //draw score
  for (int i= 0; i < [players count]; i++) {
    FZPlayer *player = [players objectAtIndex:i];
    NSString *str = [[NSString alloc] initWithFormat:@"%@\t %d\t %d",
                     player.playerName_, player.roundScore_, player.gameScore_];
    CCLabelTTF *label = [lableArray_ objectAtIndex:i];
    if (player.playerControlType_ == FZPlayer_ControlType_LocalPlayer) {
      [label setColor:ccRED];
    }
    [label setString:str];
    [str release];
  }
  
  //release
  [players release];
}

- (void)showResult{
  self.visible = YES;
  menu_.isTouchEnabled = YES;
}

- (void)hideResult{
  self.visible = NO;
  menu_.isTouchEnabled = NO;
}


- (void)okButtonClick:(id)sender{
  if ([delegate_ respondsToSelector:@selector(resultLayerOkButtonClick)]) 
	{
		[delegate_ resultLayerOkButtonClick];
	}
}

@end
