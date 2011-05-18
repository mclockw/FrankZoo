//
//  FZAI.h
//  FrankZoo
//
//  Created by wang chenzhong on 4/23/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZGameLogic.h"
#import "FZCard.h"


@interface FZMove : NSObject {
  FZCards *cards_;
  int weight;
}
@end

@interface FZAI : NSObject {
  FZGameLogic *gameLogic_;
}

- (id)initWithGameLogic:(FZGameLogic*)gameLogic;

+ (void)buildMoveListWithCardArray:(NSArray*)cardArray 
                       cardsOnDesk:(FZCards*)deckCards
                          moveList:(NSMutableArray*)moveList;
@end
