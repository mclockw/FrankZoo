//
//  FZGameLogicServer.m
//  FrankZooV1
//
//  Created by wang chenzhong on 5/11/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZGameLogicServer.h"


@implementation FZGameLogicServer

- (void)gameLoop{
  switch (gameStatus_) {
    case FZGameStatus_StartNewGame:
      gameStatus_ = FZGameStatus_WaitGameStarting;
      [self initNewGame];
      [self updateUI_initNewGame];
      gameStatus_ = FZGameStatus_PlayerDoingAction;
      break;
    case FZGameStatus_StartNewRound:
      gameStatus_ = FZGameStatus_WaitingRoundStarting;
      [self initNewRound];
      [self updateUI_initNewRound];
      gameStatus_ = FZGameStatus_PlayerDoingAction;
    case FZGameStatus_PlayerDoingAction:
      gameStatus_ = FZGameStatus_WaitPlayerAction;
      [self updateUI_playerStartAction];
      [self playerStartAction];//异步执行完成，会调用Action:cards函数，并设置Status为DoneAction
      break;
    case FZGameStatus_PlayerDoneAction: 
      gameStatus_ = FZGameStatus_WaitUpdateUI;
      if ([self isRoundOver]) {
        if ([self isGameOver]) {
          [self gameResult];
          [self updateUI_gameResult];
          gameStatus_ = FZGameStatus_GameOver;
        }else{
          [self roundResult];
          [self updateUI_roundResult]; 
          gameStatus_ = FZGameStatus_RoundOver;
        }
      }
      else {
        [self afterPlayerDoAction];
        [self updateUI_afterPlayerDoAction];       
      }
      break;
    case FZgameStatus_Pause:
    case FZGameStatus_WaitPlayerAction:
      
    case FZGameStatus_WaitGameStarting:
      
    case FZGameStatus_WaitGameResult:
    case FZGameStatus_WaitUpdateUI:
    case FZGameStatus_GameOver:
      break;
      
    default:
      break;
  }
}


#pragma mark -------------------------------------------------------------------
#pragma mark Game Process
- (void)initNewGame{
  for (FZPlayer *player in playerArray_) {
    player.gameScore_ = 0;
  }
  
  //send all Client InitNewGame
  [self sendAllClientInitNewGame];
  
  [self initNewRound];
}


- (void)initNewRound{
  [super initNewRound];
   
   
   //想每个玩家发送消息：该玩家手上的牌，第一个出牌的玩家是几号
   for (int i = 0; i < playerNum_; i++) {
     FZPlayer *player = [playerArray_ objectAtIndex:i];
     if (player.playerControlType_ == FZPlayer_ControlType_RemotPlayer){
       //
       [self sendRemotePlayer:player.peerId_ withCards:player.cardInHandArray_ firstPlayerIndex:currentPlayerIndex_];
     }
   }
}


- (void)sendRemotePlayer:(NSString*)peerId withCards:(NSArray*)cardArray firstPlayerIndex:(int)playerIndex{
  //定义Packet头为initRound
  //第二个BYTE是开始的PlayerIndex
  //15个Int表示牌
  
  
  

}

- (void)sendAllClientInitNewGame{
  //
}

@end
