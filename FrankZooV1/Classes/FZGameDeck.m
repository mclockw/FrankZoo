//
//  FZGameDeck.m
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/9/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZGameDeck.h"
#import "FZCard.h"

#define FZCARDS_NUM 60
#define ARC4RANDOM_MAX 0x100000000

@interface FZGameDeck(Private)
-(void)generateCardSet;
@end

@implementation FZGameDeck
@synthesize cardsStack_;
@synthesize cardsDeposit_;
@synthesize remainToDealCardCount_;

#pragma mark -
#pragma mark life cycle
- (void)dealloc{
    if (cardsStack_) {
        [cardsStack_ removeAllObjects];
        [cardsStack_ release];    
    }
    if (cardsDeposit_) {
        [cardsDeposit_ removeAllObjects];
        [cardsDeposit_ release];
    }
    if (currentCards_) {
        [currentCards_ release];
    }
    [super dealloc];
}

- (id)init{
    if ([super init]) {
        remainToDealCardCount_ = FZCARDS_NUM;
        cardsStack_ = [[NSMutableArray alloc] initWithCapacity:FZCARDS_NUM];
        cardsDeposit_ = [[NSMutableArray alloc] initWithCapacity:FZCARDS_NUM];
        currentCards_ = nil;
        
        [self generateCardSet];
    }
    return self;
}


#pragma mark -
#pragma mark Deal Cards
-(void)generateCardSet{
    //cardsStack_ = [[NSMutableArray alloc] initWithCapacity:FZCARDS_NUM];
    
    [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Joker]];
    
    for (int i=0;i<4; i++) {
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Mosquito]];
    }
    
    for (int i=0;i<5; i++) {
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Whale]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Elephant]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Crocodile]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_PolarBear]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Lion]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Seal]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Fox]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Perch]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Hedgehog]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Fish]];
        [cardsStack_ addObject:[FZCard cardWithCardType:FZCardType_Mouse]];
    }
    
}


-(void)shuffleCardSet{
    for(int i=0;i<FZCARDS_NUM;i++)
    {
        int new = i + (int)( (double)arc4random() / ((double)ARC4RANDOM_MAX+(double)1.0) * (FZCARDS_NUM-i)) ;
        /* swap cards */
        [cardsStack_ exchangeObjectAtIndex:i withObjectAtIndex:new];
    }
    return;
}

-(FZCard*)dealCardToPlayer{
    FZCard* card = nil;
    
    if (remainToDealCardCount_>0) {
        card = [cardsStack_ objectAtIndex:remainToDealCardCount_-1];
        //ret = [FZCard cardWithCardType:card.cardType_];
        remainToDealCardCount_--;
    }
    
    return [card retain];
}

-(void)reset{
    [self shuffleCardSet];
    remainToDealCardCount_ = FZCARDS_NUM;
}

#pragma mark -
#pragma mark Game Playing
-(void)addReposite: (FZCards*)aHandCards{
    if (cardsDeposit_) {
        for (FZCard *card in aHandCards.cardsArray_) {
            [cardsDeposit_ addObject:card];
        }
    }
}

-(void)setCurrentCards:(FZCards*)cards{
    if (cards == nil) {
        if(currentCards_) {
            [currentCards_ release];
        }
        currentCards_ = nil;
        return;
    }
    if (currentCards_) {
        [currentCards_ release];
        currentCards_ = nil;
    }
    
    currentCards_ = [cards retain];
}


-(FZCards*)getCurrentCards{
    return currentCards_;
}
//-(void)playCards:(FZCards*)cards{
//  [self addReposite:cards];
//  [self setCurrentCards:cards];
//}

@end













