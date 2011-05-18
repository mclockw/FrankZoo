//
//  PlayerUI.h
//  FrankZoo
//
//  Created by wang chenzhong on 3/29/11.
//  Copyright 2011 company. All rights reserved.
//

#import "cocos2d.h"

#import "FZCard.h"
//80 X 250

@interface UICompetitor : CCLayer {
  //CGPoint position_;
  
  CCSprite *background_;

  CCSprite *avatar_;
  CCLabelTTF *name_;
  CCLabelTTF *remainCards_;
  CCLabelTTF *score_;

  CCLabelTTF *passLable_;
  NSMutableArray *lastHandCards_;
  //FZCards *lastRoundCards_;
  //头像，名字，所剩牌数量，积分，队tag
//位置
  
  CCSprite *timeBar_;
  int remainingTime_;
}

- (void)setScore:(int)score;
- (void)setRemainCardNum:(int)num;
- (void)updateLastHand:(FZCards*)cards;

- (void)waitOthers;
- (void)currentDoAction;

- (void)arrangeUI;
//- (void)setPosition:(CGPoint)point;
- (CCSprite*)buildSmallCardSprite:(FZCardType)type;

- (void)startTimerBar;
- (void)endTimerBar;
- (void)drawBar: (ccTime) dt;
@end
