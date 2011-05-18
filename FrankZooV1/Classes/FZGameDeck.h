//
//  FZGameDeck.h
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/9/11.
//  Copyright 2011 company. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZCard;
@class FZCards;

@interface FZGameDeck : NSObject {
  FZCards *currentCards_;  
  NSMutableArray *cardsStack_;
  NSMutableArray *cardsDeposit_;
  
  int     remainToDealCardCount_;
  
}

@property(nonatomic) int remainToDealCardCount_;
@property(nonatomic, retain) NSMutableArray *cardsStack_;
@property(nonatomic, retain) NSMutableArray *cardsDeposit_;

-(void)reset;
//deal cards
-(void)shuffleCardSet;
-(FZCard*)dealCardToPlayer;

//game playing
-(void)addReposite: (FZCards*)aHandCards;
-(void)setCurrentCards: (FZCards*)cards;

//info
-(FZCards*)getCurrentCards;

//-(void)playCards:(FZCards*)cards;
@end
