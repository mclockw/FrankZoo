//
//  FZAI.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/23/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "FZAI.h"


@implementation FZMove


@end


@implementation FZAI
- (id)initWithGameLogic:(FZGameLogic*)gameLogic{
  if ([super init]) {
    gameLogic_ = gameLogic;
  }
  
  return  self;
}


//  
//  牌必须是排序的，并且JOKE牌第一，蚊子排第二，如果有的话。

//  1， 当桌面上有牌的时候
//  n张可以压它的牌类型
//  n张一样的
//  n - 1张一样的 + Joke
//  n - 1张一样的 + 蚊子 (如果是大象的话)
//  n - 2张一样的 + Joke + 蚊子(如果是大象的话)
//  
//  n+1张一样的牌
//  n + 1张该类型的牌
//  n 张该类型的牌 + Joke
//  n 张该类型的牌  + 蚊子 (如果是大象的话)
//  n - 1张该类型的牌 + Joke + 蚊子 (如果是大象的话)
//  
//  
//  
//  
//  2， 当桌面上没有牌的时候
//  遍历每个类型: 类型A一张，类型A两张，类型A三张，类型B一张，类型C一张，类型C两张....
//  如果有大象和蚊子，每种大象的牌型加一手和蚊子一起出的牌型
//  如果有Joke，以上每种牌型加一手和Joke一起出的牌型
+ (void)buildMoveListWithCardArray:(NSArray*)cardArray 
                                  cardsOnDesk:(FZCards*)deckCards
                                  moveList:(NSMutableArray*)moveList
{
  assert(moveList);
  
  [moveList removeAllObjects];
  
  //查看前两张牌
  int flagJoke = 0;
  int flagMosquito = 0;

  if ([cardArray count] >= 2) {
    for (int i = 0; i<2; i++) {
      FZCard *card = [cardArray objectAtIndex:i];
      if (card.cardType_ == FZCardType_Mosquito) {
        flagMosquito = 1;
      }
      else if (card.cardType_ == FZCardType_Joker){
        flagJoke = 1;
      }
    }
  }
  else{
    for (int i = 0; i<[cardArray count]; i++) {
      FZCard *card = [cardArray objectAtIndex:i];
      if (card.cardType_ == FZCardType_Mosquito) {
        flagMosquito = 1;
      }
      else if (card.cardType_ == FZCardType_Joker){
        flagJoke = 1;
      }
    }
  }

  //遍历
  int i = 0, j = 0;
  //FZCards* deckCards = [gameLogic_ getCurrentDeskCards];
  if (deckCards) {
    int deckCardsCount = [deckCards.cardsArray_ count];
    int findCount = 0;

    for (i = 0; i < [cardArray count]; i++) {
      FZCard *card = [cardArray objectAtIndex:i];
      if (card.cardType_ == FZCardType_Joker) {
        continue;
      }
      
      if ([card canOutrankCardType: deckCards.cardsType_] || card.cardType_ == deckCards.cardsType_) {
        findCount = 1;
        //连续找到不是同一类型的牌为止
        for (j = i + 1; j < [cardArray count]; j++) {
          FZCard * followCard = [cardArray objectAtIndex:j];
          if (followCard.cardType_ == card.cardType_) {
            findCount ++;
          }
          else{
            i = j - 1; //指向最后一张同类型的牌
            break;
          }
        }        
        
        //按findCount 添加Move
        // 加两张特殊牌
        if ((deckCardsCount > 2) && (findCount >= deckCardsCount - 2) && (card.cardType_ != deckCards.cardsType_) 
             &&(card.cardType_ == FZCardType_Elephant) && flagJoke && flagMosquito)
        {   
          [moveList addObject:[[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                          CardsNumA:deckCardsCount - 2
                                                              TypeB:FZCardType_Mosquito
                                                          CardsNumB:1
                                                              TypeC:FZCardType_Joker 
                                                          CardsNumC:1]];
        }
        if((deckCardsCount > 1) && (findCount >= deckCardsCount - 1) && (card.cardType_ == deckCards.cardsType_) 
           &&(card.cardType_ == FZCardType_Elephant) && flagJoke && flagMosquito)
        {
          [moveList addObject:[[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                        CardsNumA:deckCardsCount - 1
                                                            TypeB:FZCardType_Mosquito
                                                        CardsNumB:1
                                                            TypeC:FZCardType_Joker 
                                                        CardsNumC:1]];
        }
        // 加一张特殊牌
        if ((findCount >= deckCardsCount - 1) && (card.cardType_ != deckCards.cardsType_) && (deckCardsCount > 1))
        {
          if (flagJoke)
            [moveList addObject:[[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                          CardsNumA:deckCardsCount - 1
                                                              TypeB:FZCardType_Joker
                                                          CardsNumB:1]];
          if ((card.cardType_ == FZCardType_Elephant) && flagMosquito) 
            [moveList addObject:[[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                          CardsNumA:deckCardsCount - 1
                                                              TypeB:FZCardType_Mosquito
                                                          CardsNumB:1]];
        }
        if ((findCount >= deckCardsCount) && (card.cardType_ == deckCards.cardsType_)) 
        {
          if (flagJoke)
            [moveList addObject:[[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                          CardsNumA:deckCardsCount
                                                              TypeB:FZCardType_Joker
                                                          CardsNumB:1]];
          if ((card.cardType_ == FZCardType_Elephant) && flagMosquito) 
            [moveList addObject:[[FZCards alloc] initWithCardsTypeA:deckCards.cardsType_
                                                          CardsNumA:deckCardsCount
                                                              TypeB:FZCardType_Mosquito
                                                          CardsNumB:1]];

        }
        // 不加特殊牌
        if ((findCount >= deckCardsCount) && (card.cardType_ != deckCards.cardsType_))
        {
          [moveList addObject:[[FZCards alloc] initWithCardsType:card.cardType_ CardsNum:deckCardsCount]];
        }
        if ((findCount >= deckCardsCount + 1) && (card.cardType_ == deckCards.cardsType_)){
          [moveList addObject:[[FZCards alloc] initWithCardsType:card.cardType_ CardsNum:deckCardsCount + 1]];
        }

      }//end of 是否可以压当前桌面上的牌
      
      if (j == [cardArray count]) break;
    }//end of For Loop
  }//end of 桌面是否有牌
  else{
    //桌面上没有牌的情况
    //  遍历每个类型: 类型A一张，类型A两张，类型A三张，类型B一张，类型C一张，类型C两张....
    //  如果有大象和蚊子，每种大象的牌型加一手和蚊子一起出的牌型
    //  如果有Joke，以上每种牌型加一手和Joke一起出的牌型
    for (int i = 0; i < [cardArray count]; i++) {
      FZCard *cardI = [cardArray objectAtIndex:i];
      if (cardI.cardType_ == FZCardType_Joker) {
        continue;
      }
      [moveList addObject:[[FZCards alloc] initWithCardsType:cardI.cardType_ CardsNum:1]];
      if (flagJoke)
        [moveList addObject:[[FZCards alloc] initWithCardsTypeA:cardI.cardType_ 
                                                      CardsNumA:1 
                                                          TypeB:FZCardType_Joker 
                                                      CardsNumB:1]];
      if((cardI.cardType_ == FZCardType_Elephant) && flagJoke && flagMosquito)
        [moveList addObject:[[FZCards alloc] initWithCardsTypeA:cardI.cardType_ 
                                                      CardsNumA:1 
                                                          TypeB:FZCardType_Joker 
                                                      CardsNumB:1 
                                                          TypeC:FZCardType_Mosquito 
                                                      CardsNumC:1]];
      
      for (j = i + 1; j < [cardArray count]; j++) {
        FZCard *cardJ = [cardArray objectAtIndex:j];
        if (cardJ.cardType_ != cardI.cardType_) {
          i = j - 1;
          break;
        }

        [moveList addObject:[[FZCards alloc] initWithCardsType:cardI.cardType_ CardsNum:j - i + 1]];
        
        if (flagJoke)
          [moveList addObject:[[FZCards alloc] initWithCardsTypeA:cardI.cardType_ 
                                                        CardsNumA:j - i + 1
                                                            TypeB:FZCardType_Joker 
                                                        CardsNumB:1]];
        if((cardI.cardType_ == FZCardType_Elephant) && flagJoke && flagMosquito)
          [moveList addObject:[[FZCards alloc] initWithCardsTypeA:cardI.cardType_ 
                                                        CardsNumA:j - i + 1 
                                                            TypeB:FZCardType_Joker 
                                                        CardsNumB:1 
                                                            TypeC:FZCardType_Mosquito 
                                                        CardsNumC:1]];
      }//end of J For Loop
      
      if (j == [cardArray count]) break;
    }//end of I For Loop
  }
}

@end
