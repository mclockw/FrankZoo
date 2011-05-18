//
//  FZGameLogic.h
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZCard.h"
#import "FZGameConfig.h"
#import "FZGameDeck.h"
#import "FZPlayer.h"

typedef enum{
    FZGameStatus_StartNewGame = 0,
    FZGameStatus_WaitGameStarting,
    FZGameStatus_StartNewRound,
    FZGameStatus_WaitingDealCards,
    FZgameStatus_Pause,
    FZGameStatus_WaitingRoundStarting,
    FZGameStatus_WaitPlayerAction,
    FZGameStatus_WaitGameResult,
    FZGameStatus_WaitUpdateUI,
    FZGameStatus_PlayerDoingAction,
    FZGameStatus_PlayerDoneAction,
    FZGameStatus_RoundOver,
    FZGameStatus_GameOver
}FZGameStatus;

@interface FZGameLogic : NSObject <GameSessionDelegate> {
    FZGameConfig *gameConfig_;
    
    FZGameMode gameMode_;
    FZGameDeck *gameDeck_;
    
    NSMutableArray * playerArray_;
    FZPlayer *localPlayer_;
    
    FZGameStatus gameStatus_;
    int playerNum_;
    int currentPlayerIndex_; 
    int nextPlayerIndex_;
    int passCount_; //pass计数，用来判断何时把桌面上的牌翻掉
    int score_; //当前玩家结束时可以获得的分数
    int currentRound_;
    
    int currentPlayerNum_; //当前手上还有牌的玩家数
    
    int specialPassFlag_; //默认为0 当有玩家正好出完时候为1
    
    FZCards *currentTipsCards;
    
    id uiDelegate_;
    
    FZSessionManager *sm_;
}

@property(nonatomic, retain) NSMutableArray *playerArray_;
@property(nonatomic) int playerNum_;
@property(nonatomic, retain) FZGameDeck *gameDeck_;
@property(nonatomic) FZGameStatus gameStatus_;
@property(nonatomic) int currentRound_;
@property(nonatomic) int currentPlayerIndex_;
@property(nonatomic,retain) FZPlayer *localPlayer_;
@property(nonatomic,retain) id uiDelegate_;

- (id)initWithGameConfig:(FZGameConfig*)config 
              UIDelegate:(id)uiDelegate;

/* 游戏进程 */
- (void)startNewGame;
- (void)startNewRound;
- (void)gameLoop;

- (void)playerDoAction:(FZGameAction)action play:(FZCards*)cards;
- (void)player:(FZPlayer *)player doAction:(FZGameAction)action play:(FZCards*)cards;
- (void)playerIndex:(int)playerIndex doAction:(FZGameAction)action play:(FZCards*)cards;

- (void)initNewGame;
- (void)initNewRound;
- (void)playerStartAction;
- (void)afterPlayerDoAction;
- (void)gameResult;
- (void)roundResult;
- (void)dealCards; //发牌
- (bool)isGameOver;
- (bool)isRoundOver;


/* 游戏信息 */
- (NSArray*)getLocalPlayerCards;
- (FZCards*)getCurrentDeskCards;

/* 出牌规则 */
- (BOOL)canOutrankCardsOnDesk:(FZCards*)cards;
- (BOOL)canPass;
- (BOOL)canPlay;

/* UI Delegate */
- (void)updateUI_initNewGame;
- (void)updateUI_initNewRound;
- (void)updateUI_playerStartAction;
- (void)updateUI_playerDoAction;
- (void)updateUI_afterPlayerDoAction;
- (void)updateUI_roundResult;
- (void)updateUI_gameResult;
- (void)updateUI_cardsOnDesk;

/* Log */
- (void)log:(NSString*)inputText;

/* UI Action */
- (BOOL)localPlayerClickPlayButton; //called by UI 
- (BOOL)localPlayerClickPassButton;

@end

@protocol GameLogicUIDelegate
- (void)updateUI_initNewGame;
- (void)updateUI_initNewRound;
- (void)updateUI_playerStartAction;
- (void)updateUI_playerDoAction;
- (void)updateUI_PlayerDoAction_Animation1;
- (void)updateUI_playerDoAction_Finish;
- (void)updateUI_afterPlayerDoAction;
- (void)updateUI_roundResult;
- (void)updateUI_gameResult;
@end

