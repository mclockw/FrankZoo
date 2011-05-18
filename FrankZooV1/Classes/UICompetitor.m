//
//  PlayerUI.m
//  FrankZoo
//
//  Created by wang chenzhong on 3/29/11.
//  Copyright 2011 company. All rights reserved.
//

#import "UICompetitor.h"
#import "FZCard.h"

@implementation UICompetitor
- (void)dealloc{
  [lastHandCards_ release];
  [super dealloc];
}

- (id)init{
  self = [super init];
	
	if (self)
	{
    CGSize s;
    s.width = 250; s.height = 80;
    [self setContentSize:s];
    
    //background
    //background_
    background_ = [CCSprite spriteWithFile:@"UICompetitorBg.png"];
    [self addChild:background_];
    
    //avatar
    avatar_ = [CCSprite spriteWithFile:@"AI.png"];
    [self addChild:avatar_];

    
    //name
    name_ = [CCLabelTTF labelWithString:@"ai player" fontName:@"Arial" fontSize:12];
    [name_ setColor:ccBLACK];
    [self addChild:name_];
    
    
    //remain card count
    remainCards_ = [CCLabelTTF labelWithString:@"7" fontName:@"Arial" fontSize:12];
    [remainCards_ setColor:ccBLACK];
    [self addChild:remainCards_];
    
    
    //score
    score_ = [CCLabelTTF labelWithString:@"score" fontName:@"Arial" fontSize:12];
    [score_ setColor:ccBLACK];
    [self addChild:score_];
    //score_.visible = NO;
    
    //
    passLable_ = [CCLabelTTF labelWithString:@"pass" fontName:@"Arial" fontSize:12];
    [passLable_ setColor:ccBLUE];
    [self addChild:passLable_];
    passLable_.visible = NO;
    
    lastHandCards_ = [[NSMutableArray alloc] initWithCapacity:8];

    [self arrangeUI];
    
    
    remainingTime_ = 11;
  }
  return self;
}

- (void) arrangeUI;{
  //layer的postion在外部被设置吼，坐标系的原点在在Lyaer中原来（125, 40)的位置
  //即(125, 40)为现在的（0，0）
  avatar_.position = ccp(-100, 0);
  name_.position = ccp(-100, -30);
  timeBar_.position = ccp(-20, -30);
  remainCards_.position = ccp(-40, 0);
  score_.position = ccp(5, 0);
  passLable_.position = ccp(50, 0);
}

- (void)setScore:(int)score{
  [score_ setString:[NSString stringWithFormat:@"%d", score]];
}

- (void)setRemainCardNum:(int)num{
  [remainCards_ setString:[NSString stringWithFormat:@"%d", num]]; 
}


- (void)updateLastHand:(FZCards*)cards{
  CGPoint point = ccp(50, 0);

  //clear state
  for (CCSprite *s in lastHandCards_) {
    [self removeChild:s cleanup:YES];
  }
  passLable_.visible = NO;
  
  //set current state
  if (cards == nil) {
    passLable_.visible = YES;
  }
  else{
    for (FZCard *card in cards.cardsArray_) {
      CCSprite *cardSprite = [self buildSmallCardSprite:card.cardType_];
      cardSprite.position = point;
      cardSprite.scale =0.15;
      [self addChild:cardSprite];
      [lastHandCards_ addObject:cardSprite];
      [cardSprite release];
      
      point.x = point.x + 20;     
    }
  }
}


- (void)waitOthers{
  [background_ setColor:ccWHITE];
}
- (void)currentDoAction{
  [background_ setColor:ccRED];
}


- (CCSprite*)buildSmallCardSprite:(FZCardType)type
{
  CCSprite *sprite;
  switch (type) {
    case FZCardType_Joker:
      sprite =[[CCSprite alloc] initWithFile:@"joke_s.png"];
      break;
    case FZCardType_Mosquito: 
      sprite =[[CCSprite alloc] initWithFile:@"mosquito_s.png"];
      break;
    case FZCardType_Mouse:
      sprite =[[CCSprite alloc] initWithFile:@"mouse_s.png"];
      break;
    case FZCardType_Fish:
      sprite =[[CCSprite alloc] initWithFile:@"fish_s.png"];
      break;
    case FZCardType_Hedgehog:
      sprite =[[CCSprite alloc] initWithFile:@"hedgehog_s.png"];
      break;
    case FZCardType_Perch:
      sprite =[[CCSprite alloc] initWithFile:@"perch_s.png"];
      break;
    case FZCardType_Fox:
      sprite =[[CCSprite alloc] initWithFile:@"fox_s.png"];
      break;
    case FZCardType_Seal:
      sprite =[[CCSprite alloc] initWithFile:@"seal_s.png"];
      break;
    case FZCardType_Lion:
      sprite =[[CCSprite alloc] initWithFile:@"lion_s.png"];
      break;
    case FZCardType_PolarBear:
                                               
      sprite =[[CCSprite alloc] initWithFile:@"polarbear_s.png"];
      break;
    case FZCardType_Crocodile:
      sprite =[[CCSprite alloc] initWithFile:@"crocodile_s.png"];
      break;
    case FZCardType_Elephant:
      sprite =[[CCSprite alloc] initWithFile:@"elephant_s.png"];
      break;
    case FZCardType_Whale:
      sprite =[[CCSprite alloc] initWithFile:@"whale_s.png"];
      break;
  }  
  return sprite;
}

- (void)startTimerBar{
  remainingTime_ = 0;
//  CCTimer *timer = [CCTimer timerWithTarget:self selector:@selector(drawBar:) interval:0.1];
//  [[CCScheduler sharedScheduler] scheduleTimer:timer];

  //[self schedule: @selector(drawBar:) interval:0.1];
    //[self activateTimers];
}

- (void)endTimerBar{
 // [self deactivateTimers];

//  CCTimer *timer = [CCTimer timerWithTarget:self selector:@selector(drawBar:) interval:0.1];
//  [[CCScheduler sharedScheduler] unscheduleTimer:timer];
//  //remainingTime_ = 11;
//  [timeBar_ setScaleX:0];
}

- (void)drawBar: (ccTime)dt{	
  //draw timer bar
//  if(remainingTime_ < 10) 
//  {
//    int old = [timeBar_ boundingBox].size.width;
//    remainingTime_++;
//    [timeBar_ setScaleX:remainingTime_];
//    int new = [timeBar_ boundingBox].size.width;
//    CGPoint point = timeBar_.position;
//    point.x = point.x + (new - old)/2;
//    
//    timeBar_.position = point;
//  }
}


@end
