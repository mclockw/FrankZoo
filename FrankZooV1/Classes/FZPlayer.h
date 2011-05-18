//
//  FZPlayer.h
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZCard.h"

typedef enum{
    FZPlayer_ControlType_AI=0,
    FZPlayer_ControlType_LocalPlayer,
    FZPlayer_ControlType_RemotPlayer
}FZPlayer_ControlType;

@class FZGameLogic;

@interface FZPlayer : NSObject {
  FZPlayer_ControlType playerControlType_;
  
  int playIndex_;
  NSString *playerName_;
  
  int roundScore_;
  int gameScore_;
  
  NSMutableArray *cardInHandArray_;
  FZCards *lastHand_;
  
  NSString *peerId_;

  
@private
  FZGameLogic *gameLogic_;
  
  NSMutableArray *moveList_;
  
  int tipIndex_;
}

@property(nonatomic) FZPlayer_ControlType playerControlType_;
@property(nonatomic) int playIndex_;

@property(nonatomic) int roundScore_;
@property(nonatomic) int gameScore_;

@property(nonatomic, retain) NSMutableArray *cardInHandArray_;
@property(nonatomic, retain)  NSString *playerName_;
@property(nonatomic, retain) FZCards *lastHand_;

@property(nonatomic, retain) NSString *peerId_;

@property(nonatomic, retain) FZGameLogic *gameLogic_;

-(id)initWithName:(NSString*)name withGameLogic:(FZGameLogic*)gameLogic;
- (id)initWithControlType:(FZPlayer_ControlType)type;

/* 用户行动 */
-(void)doAction;
-(void)localPlayerAction;
-(void)remotePlayerAction;
-(void)computerAction;



/* 出牌和加牌 */
- (void)playCards:(FZCards*)cards;
- (void)addCard:(FZCard*)card;
- (void)removeAllCard;

- (void)sortCardsInHand;
- (int)getRemainCardsCount;



/* 用户信息 */
- (NSString*)getPlayerName;

/* AI */
-(void)FZAI;

//- (NSArray*)FZAI:(FZCards*)deskCards FromCardsArray:(NSArray*)cardsInHand;

//- (void)buildMoveList;

-(void)getNextTips;

@end
