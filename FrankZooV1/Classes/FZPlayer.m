//
//  FZPlayer.m
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZPlayer.h"

#import "FZGameLogic.h"
#import "FZConfig.h"
#import "FZAI.h"

//#import "GameMainViewController.h"

@implementation FZPlayer

@synthesize playerName_;
@synthesize playIndex_;
@synthesize roundScore_;
@synthesize playerControlType_;
@synthesize cardInHandArray_;
@synthesize lastHand_;
@synthesize gameScore_;
@synthesize peerId_;
@synthesize gameLogic_;

#pragma mark -
#pragma mark Player life cycle

- (id)initWithControlType:(FZPlayer_ControlType)type;
{
  [super init];
  
  if (self){
    cardInHandArray_ = [[NSMutableArray alloc] initWithCapacity:20];
    
    playIndex_ = 0;
    playerControlType_ = type;
    
    tipIndex_ = -1;
    moveList_ = [[NSMutableArray alloc] init];
    
  }
  
  return self;
  

}

- (id)init{
  [super init];
  
  if (self){
    cardInHandArray_ = [[NSMutableArray alloc] initWithCapacity:20];
    
    playIndex_ = 0;
    playerControlType_ = 0;
    
    tipIndex_ = -1;
    moveList_ = [[NSMutableArray alloc] init];

  }
  
  return self;

}

-(id)initWithName:(NSString*)name withGameLogic:(FZGameLogic*)gameLogic{
  [super init];
  [self init];
  
  if (self) {
    playerName_ = [[NSString alloc] initWithString:name];    
    gameLogic_ = gameLogic;
  }
  return self;
}

-(void) dealloc{
  [playerName_ release];
  [cardInHandArray_ release];
  if (moveList_) {
    [moveList_ release];
  }
  [super dealloc];
}

#pragma mark -
#pragma mark Player Action
-(void)doAction{
  switch (playerControlType_) {
    case FZPlayer_ControlType_AI:
      [self computerAction];
      break;
    case FZPlayer_ControlType_LocalPlayer:
      [self localPlayerAction];
      break;
    case FZPlayer_ControlType_RemotPlayer:
      [self remotePlayerAction];
      break;
      
    default:
      break;
  }	
}

-(void)localPlayerAction{
  tipIndex_ = -1;
  
  //用户通过UI来操作形成一次动作
}

-(void)remotePlayerAction{
  //通过FZSessionManager来接受一次动作
}

-(void)computerAction{
  [self FZAI];
  //[gameLogic_ playerDoAction:FZGameAction_Pass play:nil];
}

#pragma mark -
#pragma mark Play card

-(void)playCards:(FZCards*)cards {
  NSLog(@"FZPlyer retain count: %d", [cards retainCount]);
  lastHand_ = [cards retain];
  NSLog(@"FZPlyer retain count: %d", [cards retainCount]);
  for (FZCard* eachCard in cards.cardsArray_) {
    for (FZCard* eachCardInHand in cardInHandArray_) {
      if (eachCard.cardType_ == eachCardInHand.cardType_) {
        [cardInHandArray_ removeObject:eachCardInHand];
        break;
      }
    }
  } 
}

-(void)addCard:(FZCard*)card{
  [cardInHandArray_ addObject:card];
}

- (void)removeAllCard{
  [cardInHandArray_ removeAllObjects];
}

//- (void)buildMoveList{
//  NSMutableArray * moveList = [[NSMutableArray alloc] initWithCapacity:64];
//  
//  //一张牌
//  FZCard *previousCard = nil;
//  for (FZCard* card in cardInHandArray_) {
//    if (card == previousCard) {
//      continue;
//    }
//    
////    [moveList addObject:<#(id)#>
////    
////    previousCard = card;
//    
//  }
//  
//}

static int cardArrayCompareFun(id obj1, id obj2, void *context){
  FZCard *card1 = (FZCard*)obj1;
  FZCard *card2 = (FZCard*)obj2;
  
  return card1.cardType_ > card2.cardType_;
}

- (void)sortCardsInHand{
  [cardInHandArray_ sortUsingFunction:cardArrayCompareFun context:nil];
}

-(int)getRemainCardsCount{
  return [cardInHandArray_ count];
}

-(NSString*)getPlayerName{
  return playerName_;
}


#pragma mark -
#pragma mark AI
-(void)FZAI{
  /*
   1，当不能pass时
   2，当前desk上有n张
   a) 找n张可以压的牌
   b) 找n+1张同样的牌
   c) 找n张同样的牌+一张joke
   d) pass
   3，不考虑大象和蚊子的特性
   */
  
 FZCards* deckCards = [gameLogic_ getCurrentDeskCards];
  if (![gameLogic_ canPass]) {
    //找第一张不是joke的牌出
    for (FZCard *card in cardInHandArray_ ) {
      if (card.cardType_ != FZCardType_Joker) {
        FZCards *cardsToPlay = [[FZCards alloc] initWithCardsType:card.cardType_ CardsNum:1];
        [gameLogic_ playerDoAction:FZGameAction_PlayCard play:cardsToPlay];
        [cardsToPlay release];
        return;
      }
    }
  }
  
  
  int deckCardsCount = [deckCards getCardsCount];
  int cardCount = 0;
  int findFlag = 0;
  
  //2.a 找n张可以压她的牌
  for (int i = 0; i< [cardInHandArray_ count]; i++) {
    FZCard *card = [cardInHandArray_ objectAtIndex:i];
    
    if ([card canOutrankCardType:deckCards.cardsType_]) {
      if (1 == deckCardsCount) {
        FZCards *cardsToPlay = [[FZCards alloc] initWithCardsType:card.cardType_ CardsNum:1];
        [gameLogic_ playerDoAction:FZGameAction_PlayCard play:cardsToPlay];
        [cardsToPlay release];
        return;
      }
      else{
        //找n-1张
        cardCount = 1;
        for (int j=i+1; j<[cardInHandArray_ count]; j++) {
          FZCard *cardn = [cardInHandArray_ objectAtIndex:j];
          if (cardn.cardType_ == card.cardType_) {
            cardCount++;
          }
          if (cardCount == deckCardsCount) {
            findFlag = 1;
            break;
          }
        }
        if (findFlag) {
          FZCards *cardsToPlay = [[FZCards alloc] initWithCardsType:card.cardType_ CardsNum:deckCardsCount];
          [gameLogic_ playerDoAction:FZGameAction_PlayCard play:cardsToPlay];
          [cardsToPlay release];
          return;
        }
      }
    }
  }
  
  //b) 找n+1张同样的牌
  for (int i = 0; i< [cardInHandArray_ count]; i++) {
    FZCard *card = [cardInHandArray_ objectAtIndex:i];
    if (card.cardType_ == deckCards.cardsType_) {
      cardCount = 1;
      for (int j= i +1;j<[cardInHandArray_ count]; j++) {
        FZCard *cardn = [cardInHandArray_ objectAtIndex:j];
        if (cardn.cardType_ == card.cardType_) {
          cardCount++;
          if (cardCount == deckCardsCount + 1) {
            FZCards *cardsToPlay = [[FZCards alloc] initWithCardsType:card.cardType_ CardsNum:cardCount];
            [gameLogic_ playerDoAction:FZGameAction_PlayCard play:cardsToPlay];
            [cardsToPlay release];
            return;
          }
        }
      }           
      
      //c) 找n张同样的牌+一张joke
      if (cardCount == deckCardsCount) {
        for (FZCard *card in cardInHandArray_) {
          if (card.cardType_ == FZCardType_Joker) {
            FZCards *cardsToPlay = [[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                             CardsNumA:cardCount
                                                                 TypeB:FZCardType_Joker
                                                             CardsNumB:1];
            [gameLogic_ playerDoAction:FZGameAction_PlayCard play:cardsToPlay];
            [cardsToPlay release];
            return;
          }
        }
      }
    }
  }  
  
  //d) pass
  [gameLogic_ playerDoAction:FZGameAction_Pass play:nil];
  return;
}

-(void)getNextTips{
  if (tipIndex_ == -1) {
    FZCards *deckCards = [gameLogic_ getCurrentDeskCards];
    [FZAI buildMoveListWithCardArray:cardInHandArray_ cardsOnDesk:deckCards moveList:moveList_];
    tipIndex_ = 0;
  }
  
  
  for (FZCard* eachCard in cardInHandArray_) {
    eachCard.toPlayFlag = 0;
  }
  
  if (tipIndex_ == [moveList_ count]) {
    //tips user pass
    tipIndex_ = 0;
    return;
  }
  
  FZCards *tipsCards = [moveList_ objectAtIndex:tipIndex_];
  if (!tipsCards) {
    return;
  }
  
  for (FZCard* eachCard in tipsCards.cardsArray_) {
    for (FZCard* eachCardInHand in cardInHandArray_) {
      if ((eachCard.cardType_ == eachCardInHand.cardType_) 
          && (!eachCardInHand.toPlayFlag))
      {
        eachCardInHand.toPlayFlag = 1;
        break;
      }
    }
  } 

  tipIndex_++;
  if (tipIndex_ > [moveList_ count]) {
    tipIndex_ = 0;
  }
}

@end










