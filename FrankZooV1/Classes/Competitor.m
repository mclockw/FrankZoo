//
//  Competitor.m
//  FrankZooV1
//
//  Created by wang chenzhong on 4/28/11.
//  Copyright 2011 company. All rights reserved.
//

#import "Competitor.h"
#import "FZConfig.h"

@implementation Competitor
@synthesize position_;
@synthesize cardSpriteCenter_;
@synthesize cardSpriteArray_;
@synthesize playerNo_;
@synthesize cardAngle_;
@synthesize playedCardPosition_;

- (void)dealloc{  
  [parentLayer_ release];
  [super dealloc];
}

- (id)initWithLayer:(CCLayer*)layer cardAngel:(int)angle{
  [super init];
  
  if (self) {
    background_ = [CCSprite spriteWithFile:@"playerBackgroundR.png"];
    
    totalScore_ = [CCLabelTTF labelWithString:@"T" fontName:@"Arial" fontSize:9];
    [totalScore_ setColor:ccBLACK];
    
    score_  = [CCLabelTTF labelWithString:@"S" fontName:@"Arial" fontSize:9];
    [score_ setColor:ccBLACK];
    
    name_  = [CCLabelTTF labelWithString:@"Wesly" fontName:@"Arial" fontSize:12];
    [name_ setColor:ccBLACK];
    
    position_ = ccp(0,0);
    
    cardSpriteArray_ = [[NSMutableArray alloc] initWithCapacity:16];
    
    parentLayer_ = [layer retain];
    
    playerNo_ = -1;
    cardAngle_ = angle;
  }
  

  return self;
}

- (void)addToLayer:(CCLayer*)layer postion:(CGPoint)pos{
  [parentLayer_ addChild:background_];
  [parentLayer_ addChild:score_];
  [parentLayer_ addChild:totalScore_];
  [parentLayer_ addChild:name_];
  
  position_ = pos;
}

- (void)arrangeUI{
  if (position_.x != 0){
    CGPoint pos = position_;
    background_.position = position_;

    pos.x = position_.x+6; pos.y = position_.y + 10;
    totalScore_.position = pos;
    
    pos.x = position_.x - 10; pos.y = position_.y + 10;
    score_.position = pos;
    
    pos.x = position_.x +2; pos.y = position_.y - 5;
    name_.position = pos;
  }
}
- (void)setScore:(int)score{
 [score_ setString:[NSString stringWithFormat:@"%d", score]];
}


- (void)setTotalScore:(int)score{
 [totalScore_ setString:[NSString stringWithFormat:@"%d", score]];
}
- (void)setName:(NSString*)name{
  [name_ setString:name];
}

- (void)updateCards:(int)cardNum{
  int currentCardNum = [cardSpriteArray_ count];
  
  if (currentCardNum == cardNum) return;
  
  if (currentCardNum < cardNum) {
    int diff = cardNum - currentCardNum;
    for (int i = 0; i < diff; i++) {
      CCSprite * s = [CCSprite spriteWithFile:@"cardBack.png"];
      s.scale =CARD_SCALE;
      [cardSpriteArray_ addObject:s];
      [parentLayer_ addChild:s];
    }
  }else if (cardNum < currentCardNum) {
    int diff = currentCardNum - cardNum;
    for (int i = 0; i < diff; i++) {
      CCSprite * s = [cardSpriteArray_ objectAtIndex:0];
      [parentLayer_ removeChild:s cleanup:YES];
      [cardSpriteArray_ removeObjectAtIndex:0]; 
    }
  }
  
  [self arrangeCardSprite];

}

#define CARD_AREA_LENTH 400
#define OFFSET_MAX 50
- (void)arrangeCardSprite{
  //重新排列
  CGPoint pointFirstCard;
  int cardCount = [cardSpriteArray_ count];
  int offset = (CARD_AREA_LENTH - CARD_ORIGINAL_WIDTH * CARD_SCALE) / [cardSpriteArray_ count] - 1;
  if (offset > OFFSET_MAX) {
    offset = OFFSET_MAX;
  }
  
  if (playerNo_ == 1) {
    if (cardCount % 2 == 1) {
      pointFirstCard.x = cardSpriteCenter_.x;
      pointFirstCard.y = cardSpriteCenter_.y - (offset * cardCount / 2);
    }else{
      pointFirstCard.x = cardSpriteCenter_.x;
      pointFirstCard.y = cardSpriteCenter_.y - (offset * cardCount / 2) - offset / 2;
    }
    
    for (CCSprite *card in cardSpriteArray_) {
      card.position = pointFirstCard;
      pointFirstCard.y = pointFirstCard.y + offset;
      card.rotation = -90;
    }  
  }
  else if(playerNo_ == 2){
    if (cardCount % 2 == 1) {
      pointFirstCard.x = cardSpriteCenter_.x - (offset * cardCount / 2);
      pointFirstCard.y = cardSpriteCenter_.y;
    }else{
      pointFirstCard.x = cardSpriteCenter_.x - (offset * cardCount / 2) - offset / 2;
      pointFirstCard.y = cardSpriteCenter_.y;
    }
    
    for (CCSprite *card in cardSpriteArray_) {
      card.position = pointFirstCard;
      pointFirstCard.x = pointFirstCard.x + offset;
    }  
  }
  else if(playerNo_ == 3){
    if (cardCount % 2 == 1) {
      pointFirstCard.x = cardSpriteCenter_.x;
      pointFirstCard.y = cardSpriteCenter_.y - (offset * cardCount / 2);
    }else{
      pointFirstCard.x = cardSpriteCenter_.x;
      pointFirstCard.y = cardSpriteCenter_.y - (offset * cardCount / 2) - offset / 2;
    }
    
    for (CCSprite *card in cardSpriteArray_) {
      card.position = pointFirstCard;
      pointFirstCard.y = pointFirstCard.y + offset;
      card.rotation = 90;
    } 
  };



}

@end
