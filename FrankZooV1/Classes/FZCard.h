//
//  FZCard.h
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/5/11.
//  Copyright 2011 company. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
  FZCardType_Joker = 0,
  FZCardType_Mosquito = 1,//蚊子
  FZCardType_Whale = 2,       //鲸鱼
  FZCardType_Elephant,
  FZCardType_Crocodile,
  FZCardType_PolarBear,
  FZCardType_Lion,
  FZCardType_Seal,	
  FZCardType_Fox,
  FZCardType_Perch,      //鲈鱼
  FZCardType_Hedgehog,
  FZCardType_Fish,        //小丑鱼，Nemo
  FZCardType_Mouse,
}FZCardType;

#define FZCARD_OUTRANKED_BY_MOSQUITO(x)    (x |= (0x01<<1))
#define FZCARD_OUTRANKED_BY_WHALE(x) (x |= (0x01<<2))
#define FZCARD_OUTRANKED_BY_ELEPHANT(x) (x |= (0x01<<3))
#define FZCARD_OUTRANKED_BY_CROCODILE(x) (x |= (0x01<<4))
#define FZCARD_OUTRANKED_BY_POLARBEAR(x) (x |= (0x01<<5))
#define FZCARD_OUTRANKED_BY_LION(x)     (x |= (0x01<<6))
#define FZCARD_OUTRANKED_BY_SEAL(x)     (x |= (0x01<<7))
#define FZCARD_OUTRANKED_BY_FOX(x)      (x |= (0x01<<8))
#define FZCARD_OUTRANKED_BY_PERCH(x)    (x |= (0x01<<9))
#define FZCARD_OUTRANKED_BY_HEDGEHOG(x) (x |= (0x01<<10))
#define FZCARD_OUTRANKED_BY_FISH(x)        (x |= (0x01<<11))
#define FZCARD_OUTRANKED_BY_MOUSE(x)      (x |= (0x01<<12))


@interface FZCard : NSObject {
  FZCardType cardType_;
  int outranked_;
  int toPlayFlag;// for pick card to play 
}

@property (nonatomic) FZCardType cardType_;
@property (nonatomic) int outranked_;
@property (nonatomic) int toPlayFlag;

-(id) initWithCardType:(FZCardType)cardType;
-(bool) canBeOutrankedBy:(FZCard*)card;
-(bool) canOutrank:(FZCard*)card;
-(bool) canBeOutrankedByCardType:(FZCardType)cardType;
-(bool) canOutrankCardType:(FZCardType)cardType;
-(NSString *) getCardName;
@end


@interface FZCards: NSObject {
  FZCardType cardsType_;
  NSMutableArray *cardsArray_;
  bool jokeFlag_;
  bool mosquitoFlag_;
@private
  NSMutableString * cardsName_;
  
}
@property (nonatomic) FZCardType cardsType_;
@property (nonatomic, retain) NSMutableArray *cardsArray_;
@property (nonatomic) bool jokeFlag_;
@property (nonatomic) bool mosquitoFlag_;

-(int) getCardsCount;
-(id) initWithCardsType:(FZCardType)cardsType CardsNum:(int)cardsNum; 
-(id) initWithCardsTypeA:(FZCardType)cardsTypeA CardsNumA:(int)cardsNumA  
                   TypeB:(FZCardType)cardsTypeB CardsNumB:(int)cardsNumB; 
-(id) initWithCardsTypeA:(FZCardType)cardsTypeA CardsNumA:(int)cardsNumA  
                   TypeB:(FZCardType)cardsTypeB CardsNumB:(int)cardsNumB
                   TypeC:(FZCardType)cardsTypeC CardsNumC:(int)cardsNumC;
-(id) initWithCardArray:(NSArray*)cardArray;
-(void)addCard:(FZCard*)card;
-(bool) canOutrank:(FZCards*)cards;

+(BOOL) canBeAHandOfCards:(NSArray*)cardArray;

-(NSString *) getCardsName;
@end



