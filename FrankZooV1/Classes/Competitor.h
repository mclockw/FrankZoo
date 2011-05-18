//
//  Competitor.h
//  FrankZooV1
//
//  Created by wang chenzhong on 4/28/11.
//  Copyright 2011 company. All rights reserved.
//

#import "cocos2d.h"
//typedef enum {
//  Competitor_Left,
//  Competitor_Right
//}Player_Index;

@interface Competitor : NSObject {
  CCSprite *background_;
  CCLabelTTF *totalScore_;
  CCLabelTTF *score_;
  CCLabelTTF *name_;
  
  CGPoint position_;
  CGPoint cardSpriteCenter_;
  CGPoint playedCardPosition_;
  
  NSMutableArray *cardSpriteArray_;
  
  CCLayer *parentLayer_;
  
  int playerNo_;
  
  int cardAngle_;
  
}

@property(nonatomic) CGPoint position_;
@property(nonatomic) CGPoint cardSpriteCenter_;
@property(nonatomic) CGPoint playedCardPosition_;
@property(nonatomic, retain) NSMutableArray *cardSpriteArray_;
@property(nonatomic) int playerNo_;
@property(nonatomic) int cardAngle_;

- (id)initWithLayer:(CCLayer*)layer cardAngel:(int)angle;
- (void)arrangeUI;
- (void)setScore:(int)score;
- (void)setTotalScore:(int)score;
- (void)setName:(NSString*)name;


- (void)addToLayer:(CCLayer*)layer postion:(CGPoint)pos;
- (void)updateCards:(int)cardNum;
- (void)arrangeCardSprite;
@end
