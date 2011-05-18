//
//  FZGameLogic.m
//  FrankZooDemo
//
//  Created by wang chenzhong on 2/7/11.
//  Copyright 2011 company. All rights reserved.
//

#import "FZGameLogic.h"
#import "FZConfig.h"



@implementation FZGameLogic

@synthesize playerArray_;
@synthesize playerNum_;
@synthesize gameDeck_;
@synthesize gameStatus_;
@synthesize currentRound_;
@synthesize currentPlayerIndex_;
@synthesize localPlayer_;
@synthesize uiDelegate_;

#pragma mark -------------------------------------------------------------------
#pragma mark Life Cycle
- (void)dealloc{
  [gameConfig_ release];
  [sm_ release];
  
  [playerArray_ release];
  [gameDeck_ release];
  
  [super dealloc];
}

- (id)initWithGameConfig:(FZGameConfig*)config UIDelegate:(id)uiDelegate{
  [super self];
  
  if (self) {
    gameConfig_ = [config retain];
    gameMode_ = config.gameMode_;
    
    //session
    if (config.gameMode_ == FZGameModeMultiPlayerClient 
        || config.gameMode_ == FZGameModeMultiPlayerServer) {
      sm_ = [config.sm_ retain];
    }

    // players
    playerArray_ = [[NSMutableArray alloc] initWithArray:config.players_];
    localPlayer_ = [playerArray_ objectAtIndex:config.localPlayerIndex_];
    for (FZPlayer *player in playerArray_) {
      player.gameLogic_ = self;
    }
    playerNum_ = 4;
    
    //Init card set
    gameDeck_ = [[FZGameDeck alloc] init]; 
    
    //set view controller
    uiDelegate_ = uiDelegate;
    
    //PASS count
    passCount_ = -1;
    
    gameStatus_ =FZGameStatus_WaitGameStarting;
  }
  
  return self;
}

#pragma mark -------------------------------------------------------------------
#pragma mark Game Loop
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

- (void)startNewGame{
  gameStatus_ = FZGameStatus_StartNewGame;
}

- (void)startNewRound{
  gameStatus_ = FZGameStatus_StartNewRound;
}

- (void)playerDoAction:(FZGameAction)action play:(FZCards*)cards{
  NSLog(@"retain count: %d", [cards retainCount]);
  FZPlayer *player = [playerArray_ objectAtIndex:currentPlayerIndex_];
  
  if (action == FZGameAction_PlayCard) {
    [player playCards:cards];
    [gameDeck_ addReposite:cards];
    [gameDeck_ setCurrentCards:cards];
    passCount_ = 0;
    specialPassFlag_ = 0;    
  }else if (action == FZGameAction_Pass) {
    passCount_++;
    player.lastHand_ = nil;
    if (specialPassFlag_ == 1) {

      if (passCount_ == currentPlayerNum_) {
        [gameDeck_ setCurrentCards: nil];
      }
    }else {
      if (passCount_ == currentPlayerNum_ - 1) {
        [gameDeck_ setCurrentCards: nil];
      }
    }
  }
    
  //网络通迅，发送当前动作给其他网络玩家
  if (gameMode_ == FZGameModeMultiPlayerServer) {
    //本机玩家和本机AI的行动发送到客户端
    FZPlayer *player = [playerArray_ objectAtIndex:currentPlayerIndex_];
    if (player.playerControlType_ != FZPlayer_ControlType_RemotPlayer){
      [self sendToAllClientMyAction:action withCards:cards];
    }
  }else if(gameMode_ == FZGameModeMultiPlayerClient){
    FZPlayer *player = [playerArray_ objectAtIndex:currentPlayerIndex_];
    if (player.playerControlType_ != FZPlayer_ControlType_LocalPlayer){
      [self sendToServerMyAction:action withCards:cards];
    }
  }
  
  //界面更新
  [self updateUI_playerDoAction];
  
  
  NSLog(@"retain count: %d", [cards retainCount]);
}

#pragma mark -------------------------------------------------------------------
#pragma mark Game Process
- (void)initNewGame{
  for (FZPlayer *player in playerArray_) {
    player.gameScore_ = 0;
  }
  
  [self initNewRound];
}

- (void)initNewRound{
  for (FZPlayer *player in playerArray_) {
    player.roundScore_ = 0;
   
    [player.cardInHandArray_ removeAllObjects];
    player.lastHand_ = nil;
  }
  
  
  //发牌
  [self dealCards];
  
  //把随机发到牌排序便于显示
  [localPlayer_ sortCardsInHand];
  
  //随机第一个出牌的玩家
  currentPlayerIndex_ = (int)((double)arc4random() / 
                              ((double)ARC4RANDOM_MAX+(double)1.0) 
                              * (playerNum_-1));
  
  //分数
  score_ = playerNum_;
  currentPlayerNum_ = playerNum_;
  specialPassFlag_ = 0;
}

- (void)playerStartAction{
  [[playerArray_ objectAtIndex:currentPlayerIndex_] doAction];
}

- (void)afterPlayerDoAction{
  FZPlayer * player = [playerArray_ objectAtIndex:currentPlayerIndex_];
  if ([player getRemainCardsCount] == 0) {
    player.roundScore_ = score_;
    player.gameScore_ += score_;
    currentPlayerNum_--;
    score_--;
    specialPassFlag_ = 1;
  }
  
  //找到下一个手中有牌的玩家
  for (int i = 0; i < playerNum_; i++) {
    currentPlayerIndex_ = (currentPlayerIndex_+1) % playerNum_;
    player = [playerArray_ objectAtIndex:currentPlayerIndex_];
    if ([player getRemainCardsCount] > 0) {
      break;
    }
  }
}

- (void)gameResult{
  int score;
  
  for (FZPlayer *eachPlayer in playerArray_) {
    score +=[eachPlayer getRemainCardsCount];
  }
  [self log:[[NSString alloc] initWithFormat: @"%d分", score]];
  
}

- (void)roundResult{
  FZPlayer * player = [playerArray_ objectAtIndex:currentPlayerIndex_];
  player.roundScore_ = score_;
  player.gameScore_ += score_;
}

- (void)dealCards{
  [gameDeck_ reset];
  
  for (int i = 0; ; i++) {
    i = i % playerNum_;
    
    FZPlayer* player = [playerArray_ objectAtIndex:i];
    [player addCard:[gameDeck_ dealCardToPlayer]];
    
    if (gameDeck_.remainToDealCardCount_ == 0) {
      break;
    }
  }
  
}

- (bool)isGameOver{
  int pCount = 0;
  for (FZPlayer *p in playerArray_) {
    if (p.gameScore_ >= 19) pCount++;
    if (pCount >= 2) return YES;
  }

  return NO;
}
           
- (bool)isRoundOver{
  FZPlayer *player = [playerArray_ objectAtIndex:currentPlayerIndex_];
  if ([player getRemainCardsCount]==0) {
    int pCount = 0;
    for (FZPlayer *p in playerArray_) {
      if ([p getRemainCardsCount] == 0) {
        pCount++;
        if (pCount == playerNum_ - 1) return YES;
      }
    }
  }
  return NO;
}

- (void)resetGame{
  //clear cards in player hand
  for (FZPlayer *player in playerArray_) {
    [player.cardInHandArray_ removeAllObjects];
    player.gameScore_ = 0;
    player.roundScore_ = 0;
  }
  
  //clear game deck
  [gameDeck_.cardsDeposit_ removeAllObjects];
  [gameDeck_ setCurrentCards: nil];

}
#pragma mark -------------------------------------------------------------------
#pragma mark Game Info
- (FZPlayer*)getLocalPlayer{
  return [playerArray_ objectAtIndex:0];
}

- (NSArray*)getLocalPlayerCards{
  FZPlayer * player = [playerArray_ objectAtIndex:0];
  if (player) {
    return [player cardInHandArray_];
  }
  else {
    return nil;
  }
}

- (FZCards*)getCurrentDeskCards{
  return [gameDeck_ getCurrentCards];
}

#pragma mark -------------------------------------------------------------------
#pragma mark Call Back Function
- (BOOL)localPlayerClickPlayButton{
  if ([self canPlay]){
    //find cards which are choiced to play
    NSMutableArray *cardToPlay = [[NSMutableArray alloc] initWithCapacity:10];
    for (FZCard *card in [self getLocalPlayerCards]) {
      if (card.toPlayFlag) {
        [cardToPlay addObject:card];
      }
    }
    FZCards *cards= [[FZCards alloc] initWithCardArray:cardToPlay];
    [self playerDoAction:FZGameAction_PlayCard play:cards];
    
    [cardToPlay release];
    [cards release];
    
    return YES;
  }
  
  return NO;
}

- (BOOL)localPlayerClickPassButton{
  if ([self canPass]){
    [self playerDoAction:FZGameAction_Pass play:nil];
    return YES;
  }
  
  return NO;
}

#pragma mark -------------------------------------------------------------------
#pragma mark Mutiplayer
- (void)recieveRemotePlayerAction:(NSData*)data{
  unsigned char *byte  = (unsigned char *)[data bytes];
  FZPacketHeader header = byte[0];
  if (header != FZPacketHeaderAction) {
    return;
  }
  
  if (gameMode_ == FZGameModeMultiPlayerServer) {
    [self forwardActionToAllClint:data];
  }
  
  FZGameAction actionByte = byte[1];
  if (actionByte == FZGameAction_Pass) {
    [self playerDoAction:FZGameAction_Pass play:nil];
  }
  else if (actionByte == FZGameAction_PlayCard){
    //   
    //           Position    Next Word
    //   2Bit|1|1|<------- 12bit ------->|
    //	*|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    //	*|1|1|x|x| | | | | | | | | | | | | 
    //	*|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
    
    int cardNum = ((byte[3] & 0xC0) >> 6) + 1;
    int jokeFlag =(byte[3] & 0x20) >> 5;
    int mosquitoFlag = (byte[3] & 0x01) >> 4;
    FZCardType cardType = ((byte[3] & 0x0F ) << 8) || byte[4];

    FZCards *cards;
    if (jokeFlag && mosquitoFlag) {
      cards = [[FZCards alloc] initWithCardsTypeA:cardType CardsNumA:cardNum
                                                     TypeB:FZCardType_Joker CardsNumB:1 
                                                     TypeC:FZCardType_Mosquito CardsNumC:1];
    }
    else if(jokeFlag){
      cards = [[FZCards alloc] initWithCardsTypeA:cardType CardsNumA:cardNum
                                                     TypeB:FZCardType_Joker CardsNumB:1];
    }else if(mosquitoFlag){
      cards = [[FZCards alloc] initWithCardsTypeA:cardType CardsNumA:cardNum
                                                     TypeB:FZCardType_Mosquito CardsNumB:1];
    }
    else{
      cards = [[FZCards alloc] initWithCardsType:cardType CardsNum:cardNum];
    }
    
    [self playerDoAction:FZGameAction_PlayCard play:cards];
    [cards release];
  }
}

- (NSData*)buildPacketWithAction:(FZGameAction)action withCards:(FZCards*)cards{
  unsigned char bytes[4] = {0};
  bytes[0] = FZPacketHeaderAction;
  
  if (action == FZGameAction_Pass) {
    bytes[1] = FZGameAction_Pass;
  }else if(action == FZGameAction_PlayCard){
    bytes[1] = FZGameAction_PlayCard;
    
    int cardNum ;
    if (cards.mosquitoFlag_ && cards.jokeFlag_) {
      cardNum = [cards.cardsArray_ count] - 3;
      bytes[2] |= 0x01 << 5;//joke bit
      bytes[2] |= 0x01 << 4;//mosquito bit
    }
    else if(cards.mosquitoFlag_)
    {
      cardNum = [cards.cardsArray_ count] - 2;
      bytes[2] |= 0x01 << 4;//mosquito bit
    }else if(cards.jokeFlag_){
      cardNum = [cards.cardsArray_ count] - 2;
      bytes[2] |= 0x01 << 5;//joke bit
    }else{
      cardNum = [cards.cardsArray_ count] - 1;
    }
    
    bytes[2] |= cardNum << 6;    
    bytes[2] |= (cards.cardsType_ >> 8) & 0x0F;
    
    bytes[3] |= cards.cardsType_ & 0xFF;
  }
  
  NSData *data = [[NSData alloc] initWithBytes:bytes length:4];
  
  return [data autorelease];
}


- (void)sendToAllClientMyAction:(FZGameAction)action withCards:(FZCards*)cards{
  NSData *data = [self buildPacketWithAction: action withCards:cards];
  [sm_ sendToServer:data];
}
       
- (void)sendToServerMyAction:(FZGameAction)action withCards:(FZCards*)cards{
  NSData *data = [self buildPacketWithAction: action withCards:cards];
  [sm_ sendToServer:data];
}

- (void)forwardActionToAllClint:(NSData*)data{
  [sm_ forwardActionToAllClint:data];
}

//- (void)remotePlayerAction:(FZGameAction)action play:(FZCards*)cards{
//  
//}
//
//
//- (void)remotePlayerQuitGame{
//
//}
//
//
//- (void)sendAllRemotePlayerAction{
//  
//}
//
//- (void)allRemotePlayerComfirmAction{
//
//}



#pragma mark -------------------------------------------------------------------
#pragma mark Game Rule
- (BOOL)canOutrankCardsOnDesk:(FZCards*)cards{
  if ([gameDeck_ getCurrentCards]==nil) {
    return YES;
  }else {
    if ([cards canOutrank:[gameDeck_ getCurrentCards]]) {
      return YES;
    }
    else {
      return NO;
    }
  }
}

- (BOOL)canPass{
  //第一个出牌 不能pass
  if (passCount_ == -1) return NO;
  
  //当剩下一张牌为joke时，可以pass
  FZPlayer *player = [playerArray_ objectAtIndex:currentPlayerIndex_];
  if ([player.cardInHandArray_ count] == 1) {
    FZCard * card = [player.cardInHandArray_ objectAtIndex:0];
    if (card.cardType_ == FZCardType_Joker) {
      return YES;
    }
  }
  
  //正常情况下passcount == playerNum - 1就不能pass了
  //在某个人正好出完的情况下，passcount可以当前玩家数
  if (specialPassFlag_ == 1) {
    if (passCount_ == currentPlayerNum_) return NO;
    else return YES;
  }
  
  if (passCount_ == currentPlayerNum_ - 1) return NO;

  return YES;
}

- (BOOL)canPlay{
  //find cards which are choiced to play
  NSMutableArray *cardToPlay = [[NSMutableArray alloc] initWithCapacity:10];
  for (FZCard *card in [self getLocalPlayerCards]) {
    if (card.toPlayFlag) {
      [cardToPlay addObject:card];
    }
  }
  
  if ([cardToPlay count] == 0) {
    if (![self canPass]) {
      [cardToPlay release];
      [self log:@"can not pass!"];
      return NO;
    }
   // [self playerDoAction:FZGameAction_Pass play:nil];
    [cardToPlay release];
    return YES;
  }
  
  if (![FZCards canBeAHandOfCards:cardToPlay]) {
    [self log:@"选择的牌不能一起出。"];
    [cardToPlay release];
    return NO;
  }
  
  FZCards *cards= [[FZCards alloc] initWithCardArray:cardToPlay];
  
  if (![self canOutrankCardsOnDesk:cards]) {
    [self log:@"选择的牌不能压桌面上的牌。"];
    [cardToPlay release];
    [cards release];
    return NO;
  }
  
  [cards release];
  [cardToPlay release]; 
  return YES;
}

#pragma mark -------------------------------------------------------------------
#pragma mark UI Delegate
- (void)updateUI_initNewGame{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_initNewGame)]) 
	{
		[uiDelegate_ updateUI_initNewGame];
	}
}

- (void)updateUI_initNewRound{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_initNewRound)]) 
	{
		[uiDelegate_ updateUI_initNewRound];
	}
}

- (void)updateUI_playerStartAction{
if ([uiDelegate_ respondsToSelector:@selector(updateUI_playerStartAction)]) 
	{
		[uiDelegate_ updateUI_playerStartAction];
	}
}

- (void)updateUI_playerDoAction{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_playerDoAction)]) 
	{
		[uiDelegate_ updateUI_playerDoAction];
	}
}

- (void)updateUI_cardsOnDesk{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_cardsOnDesk)]) 
	{
		[uiDelegate_ updateUI_cardsOnDesk];
	}
}

- (void)updateUI_afterPlayerDoAction{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_afterPlayerDoAction)]) 
	{
		[uiDelegate_ updateUI_afterPlayerDoAction];
	}
}

- (void)updateUI_roundResult{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_roundResult)]) 
	{
		[uiDelegate_ updateUI_roundResult];
	}
}

- (void)updateUI_gameResult{
  if ([uiDelegate_ respondsToSelector:@selector(updateUI_gameResult)]) 
	{
		[uiDelegate_ updateUI_gameResult];
	}
}

- (void)log:(NSString*)inputText{
  if (FZLOG_FLAG){
    if ([uiDelegate_ respondsToSelector:@selector(log:)]) 
    {
      [uiDelegate_ log:inputText];
    }
  }
}






@end
