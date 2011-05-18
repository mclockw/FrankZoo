//
//  FZCard.m
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/5/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZCard.h"

#pragma mark -
#pragma mark FZCard

@implementation FZCard

@synthesize cardType_;
@synthesize outranked_;
@synthesize toPlayFlag;

+ (id)cardWithCardType:(FZCardType)cardType {
    return [[[FZCard alloc] initWithCardType:cardType] autorelease];
}

-(id) initWithCardType:(FZCardType)cardType{
    if (self) {
        outranked_=0;
        cardType_ = cardType;
        toPlayFlag = 0;
        
        switch (cardType) {
            case FZCardType_Joker:
                break;
            case FZCardType_Mosquito:
            {
                FZCARD_OUTRANKED_BY_HEDGEHOG(outranked_);
                FZCARD_OUTRANKED_BY_FISH(outranked_);
                FZCARD_OUTRANKED_BY_MOUSE(outranked_);
                break;
            }
            case FZCardType_Mouse:
                FZCARD_OUTRANKED_BY_CROCODILE(outranked_);
                FZCARD_OUTRANKED_BY_POLARBEAR(outranked_);
                FZCARD_OUTRANKED_BY_LION(outranked_);
                FZCARD_OUTRANKED_BY_SEAL(outranked_);
                FZCARD_OUTRANKED_BY_FOX(outranked_);
                FZCARD_OUTRANKED_BY_HEDGEHOG(outranked_);
                break;
            case FZCardType_Fish:
                FZCARD_OUTRANKED_BY_WHALE(outranked_);
                FZCARD_OUTRANKED_BY_CROCODILE(outranked_);
                FZCARD_OUTRANKED_BY_SEAL(outranked_);
                FZCARD_OUTRANKED_BY_PERCH(outranked_);
                break;
            case FZCardType_Hedgehog:
                FZCARD_OUTRANKED_BY_FOX(outranked_);
                break;
            case FZCardType_Perch:
                FZCARD_OUTRANKED_BY_WHALE(outranked_);
                FZCARD_OUTRANKED_BY_CROCODILE(outranked_);
                FZCARD_OUTRANKED_BY_POLARBEAR(outranked_);
                FZCARD_OUTRANKED_BY_SEAL(outranked_);
                break;
            case FZCardType_Fox:
                FZCARD_OUTRANKED_BY_ELEPHANT(outranked_);
                FZCARD_OUTRANKED_BY_CROCODILE(outranked_);
                FZCARD_OUTRANKED_BY_POLARBEAR(outranked_);
                FZCARD_OUTRANKED_BY_LION(outranked_);
                break;
            case FZCardType_Seal:
                FZCARD_OUTRANKED_BY_WHALE(outranked_);
                FZCARD_OUTRANKED_BY_POLARBEAR(outranked_);
                break;
            case FZCardType_Lion:
                FZCARD_OUTRANKED_BY_ELEPHANT(outranked_);
                break;
            case FZCardType_PolarBear:
                FZCARD_OUTRANKED_BY_WHALE(outranked_);
                FZCARD_OUTRANKED_BY_ELEPHANT(outranked_);
                break;
            case FZCardType_Crocodile:
                FZCARD_OUTRANKED_BY_ELEPHANT(outranked_);
                break;
            case FZCardType_Elephant:
                FZCARD_OUTRANKED_BY_MOUSE(outranked_);
                break;
            case FZCardType_Whale:
                break;
        }
    }
    
    return self;
}

-(bool) canBeOutrankedBy:(FZCard*)card{
    return self.outranked_ & (0x01 << card.cardType_);
}

-(bool) canOutrank:(FZCard*)card{
    return card.outranked_ & (0x01 << self.cardType_);
}

-(bool) canBeOutrankedByCardType:(FZCardType)cardType{
    return self.outranked_ & (0x01 << cardType);
}

-(bool) canOutrankCardType:(FZCardType)cardType{
    bool ret;
    FZCard * card = [[FZCard alloc] initWithCardType:cardType];
    ret = [self canOutrank:card];
    [card release];
    
    return ret;
}

-(NSString *) getCardName
{
    NSString * cardName;
    switch (cardType_) {
        case FZCardType_Joker:
            cardName = [NSString stringWithString:@"Joker"];
            break;
        case FZCardType_Mosquito:
            cardName = [NSString stringWithString:@"Mosquito"];
            break;
        case FZCardType_Mouse:
            cardName = [NSString stringWithString:@"Mouse"];
            break;
        case FZCardType_Fish:
            cardName = [NSString stringWithString:@"Fish"];
            break;
        case FZCardType_Hedgehog:
            cardName = [NSString stringWithString:@"Hedgehog"];
            break;
        case FZCardType_Perch:
            cardName = [NSString stringWithString:@"Perch"];
            break;
        case FZCardType_Fox:
            cardName = [NSString stringWithString:@"Fox"];
            break;
        case FZCardType_Seal:
            cardName = [NSString stringWithString:@"Seal"];
            break;
        case FZCardType_Lion:
            cardName = [NSString stringWithString:@"Lion"];
            break;
        case FZCardType_PolarBear:
            cardName = [NSString stringWithString:@"PolarBear"];
            break;
        case FZCardType_Crocodile:
            cardName = [NSString stringWithString:@"Crocodile"];
            break;
        case FZCardType_Elephant:
            cardName = [NSString stringWithString:@"Elephant"];
            break;
        case FZCardType_Whale:
            cardName = [NSString stringWithString:@"Whale"];
            break;
    }
    
    return cardName;
}

- (CardSprite*)buildCardSprite{
    CardSprite *sprite;
    switch (cardType_) {
        case FZCardType_Joker:
            sprite =[CardSprite spriteWithFile:@"Joke.png"];
            break;
        case FZCardType_Mosquito: 
            sprite =[CardSprite spriteWithFile:@"Mosquito.png"];
            break;
        case FZCardType_Mouse:
            sprite =[CardSprite spriteWithFile:@"Mouse.png"];
            break;
        case FZCardType_Fish:
            sprite =[CardSprite spriteWithFile:@"Fish.png"];
            break;
        case FZCardType_Hedgehog:
            sprite =[CardSprite spriteWithFile:@"Hedgehog.png"];
            break;
        case FZCardType_Perch:
            sprite =[CardSprite spriteWithFile:@"Perch.png"];
            break;
        case FZCardType_Fox:
            sprite =[CardSprite spriteWithFile:@"Fox.png"];
            break;
        case FZCardType_Seal:
            sprite =[CardSprite spriteWithFile:@"Seal.png"];
            break;
        case FZCardType_Lion:
            sprite =[CardSprite spriteWithFile:@"Lion.png"];
            break;
        case FZCardType_PolarBear:
            sprite =[CardSprite spriteWithFile:@"Polarbear.png"];
            break;
        case FZCardType_Crocodile:
            sprite =[CardSprite spriteWithFile:@"Crocodile.png"];
            break;
        case FZCardType_Elephant:
            sprite =[CardSprite spriteWithFile:@"Elephant.png"];
            break;
        case FZCardType_Whale:
            sprite =[CardSprite spriteWithFile:@"Whale.png"];
            break;
    }  
    return sprite;
}

@end

#pragma mark -
#pragma mark FZCards
@implementation FZCards

@synthesize cardsType_;
@synthesize cardsArray_;
@synthesize mosquitoFlag_;
@synthesize jokeFlag_;

+(id) cardsWithCardsType:(FZCardType)cardsType CardsNum:(int)cardsNum {
    return [[[FZCards alloc] initWithCardsType:cardsType CardsNum:cardsNum] autorelease];
}

+(id) cardsWithCardsTypeA:(FZCardType)cardsTypeA CardsNumA:(int)cardsNumA  
                    TypeB:(FZCardType)cardsTypeB CardsNumB:(int)cardsNumB {
    return [[[FZCards alloc] initWithCardsTypeA:cardsTypeA CardsNumA:cardsNumA TypeB:cardsTypeB CardsNumB:cardsNumB] autorelease];
}

+(id) cardsWithCardsTypeA:(FZCardType)cardsTypeA CardsNumA:(int)cardsNumA  
                    TypeB:(FZCardType)cardsTypeB CardsNumB:(int)cardsNumB
                    TypeC:(FZCardType)cardsTypeC CardsNumC:(int)cardsNumC {
    return [[[FZCards alloc] initWithCardsTypeA:cardsTypeA CardsNumA:cardsNumA TypeB:cardsTypeB CardsNumB:cardsNumB TypeC:cardsTypeC CardsNumC:cardsNumC] autorelease];
}

+(id) cardsWithCardArray:(NSArray*)cardArray {
    return [[[FZCards alloc] initWithCardArray:cardArray] autorelease];
}

-(id) initWithCardsType:(FZCardType)cardsType CardsNum:(int)cardsNum
{
    if (self) {
        cardsType_ = cardsType;
        
        if (cardsNum<=0) {
            cardsNum = 1;
        }
        cardsArray_ = [[NSMutableArray alloc] initWithCapacity:cardsNum];
        for (int i=0; i<cardsNum; i++) {
            [self addCard:[FZCard cardWithCardType:cardsType]];
        }
    }
    
    cardsName_ = [[NSMutableString alloc] initWithCapacity:1024];
    for (FZCard* card in cardsArray_) {
        [cardsName_ appendFormat: @"|| %@",[card getCardName]];
    }
    
    return self;
}

-(id) initWithCardsTypeA:(FZCardType)cardsTypeA CardsNumA:(int)cardsNumA  
                   TypeB:(FZCardType)cardsTypeB CardsNumB:(int)cardsNumB 
{
    if (self) {
        cardsType_ = cardsTypeA;
        
        if (cardsNumA<=0) {
            cardsNumA = 1;
        }
        cardsArray_ = [[NSMutableArray alloc] initWithCapacity:cardsNumA+cardsNumB];
        
        for (int i=0; i<cardsNumA; i++) {
            [self addCard:[FZCard cardWithCardType:cardsTypeA]];
        }
        for (int i=0; i<cardsNumB; i++) {
            [self addCard:[FZCard cardWithCardType:cardsTypeB]];
        }
    }
    
    if (cardsTypeB == FZCardType_Joker) {
        jokeFlag_ = YES;
    }else if(cardsTypeB == FZCardType_Mosquito){
        mosquitoFlag_ = YES;
    }
    
    cardsName_ = [[NSMutableString alloc] initWithCapacity:1024];
    for (FZCard* card in cardsArray_) {
        [cardsName_ appendFormat: @"|| %@",[card getCardName]];
    }
    
    return self;
}

-(id) initWithCardsTypeA:(FZCardType)cardsTypeA CardsNumA:(int)cardsNumA  
                   TypeB:(FZCardType)cardsTypeB CardsNumB:(int)cardsNumB
                   TypeC:(FZCardType)cardsTypeC CardsNumC:(int)cardsNumC 
{
    if (self) {
        cardsType_ = cardsTypeA;
        
        if (cardsNumA<=0) {
            cardsNumA = 1;
        }
        cardsArray_ = [[NSMutableArray alloc] initWithCapacity:cardsNumA+cardsNumB+cardsNumC];
        
        for (int i=0; i<cardsNumA; i++) {
            [self addCard:[FZCard cardWithCardType:cardsTypeA]];
        }
        for (int i=0; i<cardsNumB; i++) {
            [self addCard:[FZCard cardWithCardType:cardsTypeB]];
        }
        for (int i=0; i<cardsNumC; i++) {
            [self addCard:[FZCard cardWithCardType:cardsTypeC]];
        }
        
        jokeFlag_ = YES;
        mosquitoFlag_ = YES;
    }
    
    cardsName_ = [[NSMutableString alloc] initWithCapacity:1024];
    for (FZCard* card in cardsArray_) {
        [cardsName_ appendFormat: @"|| %@",[card getCardName]];
    }
    
    return self;
}


-(id) initWithCardArray:(NSArray*)cardArray{
    if (self && [FZCards canBeAHandOfCards:cardArray]) {
        cardsArray_ = [[NSMutableArray alloc] initWithCapacity:[cardArray count]];
        for (FZCard *card in cardArray) {
            [self addCard:card];
            if (card.cardType_==FZCardType_Joker) {
                continue;
            }
            if (card.cardType_==FZCardType_Mosquito) {
                if (cardsType_==FZCardType_Elephant) {
                    continue;
                }else {
                    cardsType_=FZCardType_Mosquito;
                }
            }
            else {
                cardsType_=card.cardType_;
            }
        }
    }
    
    cardsName_ = [[NSMutableString alloc] initWithCapacity:1024];
    for (FZCard* card in cardsArray_) {
        [cardsName_ appendFormat: @"|| %@",[card getCardName]];
    }
    
    return self;
}


//什么样的牌可以组成一手牌
//1)同样的 2）joke+任何牌 3）蚊子 + 大象
+(BOOL) canBeAHandOfCards:(NSArray*)cardArray{
    int jokeFlag = 0;
    int mosquitoFlag = 0;
    int elephantFlag = 0;
    FZCardType otherType_ = 0;
    
    if ([cardArray count] == 1) {
        FZCard* card = [cardArray objectAtIndex:0];
        if (card.cardType_ == FZCardType_Joker) {
            return NO;
        }
        else {
            return YES;
        }
        
    }
    
    for (FZCard* card in cardArray) {
        switch (card.cardType_) {
            case FZCardType_Joker:
                jokeFlag ++;
                break;
            case FZCardType_Mosquito:
                mosquitoFlag ++;
                break;
            case FZCardType_Elephant:
                elephantFlag ++;
                break;
            default:
                if(otherType_==0) otherType_ = card.cardType_;
                else if(otherType_ != card.cardType_) return NO;  
                break;
        } 
    }
    
    if ((elephantFlag > 0) && (mosquitoFlag >1)) {
        return NO;
    }
    
    if (otherType_>0) {
        if (mosquitoFlag>0 || elephantFlag>0) {
            return NO;
        }
    }
    
    
    return YES;
}




-(void)addCard:(FZCard*)card{
    // FZCard* tempCard = [card copy];
    [cardsArray_ addObject:card];
    //[tempCard release];
}

-(int) getCardsCount{
    return [cardsArray_ count];
}

-(bool) canOutrank:(FZCards*)cards{
    bool ret;
    
    if ([self getCardsCount]<1 || [cards getCardsCount]<1) {
        ret = NO;
    }
    
    FZCard* card = [[FZCard alloc] initWithCardType:self.cardsType_];
    
    if ([self getCardsCount] == [cards getCardsCount]) {
        ret = [card canOutrankCardType:cards.cardsType_];
    }
    else if([self getCardsCount] == [cards getCardsCount]+1){
        ret = (self.cardsType_== cards.cardsType_);
    }
    else {
        ret = NO;
    }
    
    [card release];
    
    return ret;
}

- (void)dealloc {
    [cardsName_ release];
    [cardsArray_ release];
    [super dealloc];
}

-(NSString *) getCardsName{
    return cardsName_;
}


@end

