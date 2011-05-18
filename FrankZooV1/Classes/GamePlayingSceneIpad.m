//
//  GamePlayingSceneIpad.m
//  FrankZoo
//
//  Created by wang chenzhong on 4/18/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "GamePlayingSceneIpad.h"
#import "FZGameConfig.h"
#import "FZGameLogic.h"
#import "FZPlayer.h"
#import "AppConfig.h"
#import "FZConfig.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "Competitor.h"
#import "MainMenuScene.h"
#import "FZGameLogicServer.h"

extern ST_APPCONFIG g_stAppConfing;

#define CARD_SCALE 0.75
#define CARD_SCALE_LARGE 1.5
#define CARD_ORIGINAL_WIDTH 134
#define CARD_ORIGINAL_HEIGHT 204
#define CARD_WIDTH 67
#define CARD_AREA_WIDTH 760
#define CARD_GAP 10
#define CARD_STACK_POSITION ccp(512, 384)
#define PLAYER_NUMER 4

#define Z_ORDER_TIMEBAR 101
#define Z_ORDER_BACKGROUND -1
#define Z_ORDER_RESULT_LAYER 150
#define Z_ORDER_GAME_MENU 200

static const ccColor3B CARD_GRAY={220,220,220};

#pragma mark -------------------------------------------------------------------
#pragma mark Scene Node
@implementation GamePlayingSceneIpad
-(id)initWithGameConfig:(FZGameConfig*)config{
  if ([super init]) {
    GamePlayingLayerIpad *layer = [[GamePlayingLayerIpad alloc]
                                        initWithGameConfig:config];
    [self addChild:layer];
    [layer release];
  }

  return self;
}
@end

@implementation GamePlayingLayerIpad
#pragma mark -------------------------------------------------------------------
#pragma mark 初始化
- (void) dealloc{
  if (gameLogic_) {
    [gameLogic_ release];
  }
  
  [cardSpriteArray_ release];
  [cardsOnDesk_ release];
  [competitorArray_ release];
  
	[super dealloc];
}

- (id)initWithGameConfig:(FZGameConfig*)config{
  [super init];
  
  if (self) {
    gameConfig_ = [config retain];

    //Background
    CCSprite *background = [CCSprite spriteWithFile:@"gamelayer_background_ipad.png"];
    background.anchorPoint = ccp(0, 0);
    [self addChild:background z:Z_ORDER_BACKGROUND];
    
    //menu
    [CCMenuItemFont setFontSize:20];
    [CCMenuItemFont setFontName:@"Marker Felt"];
    CCMenuItem *menu = [CCMenuItemFont itemFromString:@"menu"
                                               target:self
                                             selector:@selector(menuButtonClick:)];
    menu_ = [CCMenu menuWithItems:menu, nil];
    [self addChild:menu_];
    
    //play or pass menu
    actionButton_ = [CCLabelTTF labelWithString:@"pass" fontName:@"Arial" fontSize:30];
    [actionButton_ setColor:ccBLUE];
    CCMenuItem *action = [CCMenuItemLabel itemWithLabel:actionButton_ 
                                                 target:self 
                                               selector:@selector(actionButtonClick:)];
    actionMenu_ = [CCMenu menuWithItems:action, nil];
    [self addChild:actionMenu_];
    actionMenu_.visible = NO;
    playOrPassFlag_ = 0;
    
    //tips and reset menu
    helpActionButton_ = [CCLabelTTF labelWithString:@"tips" fontName:@"Arial" fontSize:30];
    [helpActionButton_ setColor:ccBLUE];
    CCMenuItem *haction = [CCMenuItemLabel itemWithLabel:helpActionButton_ 
                                                  target:self 
                                                selector:@selector(helpActionButtonClick:)];
    helpActionMenu_ = [CCMenu menuWithItems:haction, nil];
    tipsOrRestFlag_ = 1;
    [self addChild:helpActionMenu_];
    helpActionMenu_.visible = NO;
    
    //Result Layer
    resultLayer_ = [[ResultLayer alloc] init];
    resultLayer_.delegate_ = self;
    [self addChild:resultLayer_ z:Z_ORDER_RESULT_LAYER];
    resultLayer_.position = ccp(512, 384);
    [resultLayer_ hideResult];
    
    //Game Menu Layer
    menuLayer_ = [[GameMenuLayer alloc] init];
    menuLayer_.delegate_ = self;
    [self addChild: menuLayer_ z: Z_ORDER_GAME_MENU];
    menuLayer_.position = ccp(512, 384);
    menuLayer_.visible = NO;
    
    //create time bar
    timeBar_ = [CCSprite spriteWithFile:@"timebar.png"];
    timeBar_.scaleX = 0;
    timeBar_.scaleY = 0.5;
    timeBar_.anchorPoint = ccp(0, 0);    
    [self addChild:timeBar_ z:Z_ORDER_TIMEBAR];
    
    //cards 
    cardSpriteArray_=[[NSMutableArray alloc] initWithCapacity:8];
    cardsOnDesk_ = [[NSMutableArray alloc] initWithCapacity:8];
    
    //competitor 
    competitorArray_ = [[NSMutableArray alloc] initWithCapacity:8];
    CGPoint pos[3] = {ccp(150, 285), ccp(250, 650), ccp(900, 600)};
    CGPoint cardPos[3] = {ccp(0, 384), ccp(512, 768), ccp(1024, 384)};
    CGPoint playCardPos[3] = {ccp(200, 384), ccp(512, 568), ccp(824, 384)};
    int angle[3] = {-90, 180, 90};
    for (int i = 0; i < PLAYER_NUMER -1; i++) {
      Competitor * c = [[Competitor alloc] initWithLayer:self cardAngel:angle[0]];
      
      c.cardSpriteCenter_ = cardPos[i];
      c.playedCardPosition_ = playCardPos[i];
      c.playerNo_ = i + 1;
      
      FZPlayer *player = [gameConfig_.players_ objectAtIndex:i+1];
      [c setName:player.playerName_ ];
      
      [c addToLayer:self postion:pos[i]];
      [c arrangeUI];
      [competitorArray_ addObject:c];
      [c release];
    }  
    /* layout element postion */
    [self arrangeUI];
    
    /* start a new game */
    [self startNewGame];
  }
  
  return self;
}

- (void)arrangeUI{
  menu_.position = ccp(1000,760);
  
  actionMenu_.position = ccp(640, 260);
  helpActionMenu_.position = ccp(850, 260); 
}


#pragma mark -------------------------------------------------------------------
#pragma mark 开始新游戏
- (void)startNewGame{
  /* Clear All */
  for (CCSprite *sprt in cardSpriteArray_) {
    [self removeChild:sprt cleanup:YES];
  }
  [cardSpriteArray_ removeAllObjects];
  
  for (CCSprite *sprt in cardsOnDesk_) {
    [self removeChild:sprt cleanup:YES];
  }
  [cardsOnDesk_ removeAllObjects];
  
  selectCardNum_ = 0;
  currentPlayerIndex_ = 0;
  tipIndex = 0;
  
  for (Competitor *c in competitorArray_) {
    [c setScore:0];
    [c setTotalScore:0];
  }

  /* alloc and init Game Logic */
  if (gameLogic_) {
    [gameLogic_ release];
    gameLogic_ = nil;
  }

  gameLogic_ = [[FZGameLogic alloc] initWithGameConfig:gameConfig_ UIDelegate:self];
  //gameLogic_ = [[FZGameLogicServer alloc] initWithGameConfig:gameConfig_ UIDelegate:self];

  //game loop
  [self schedule: @selector(tick:) interval:FRAMERATE];
  
  //Game Logis设置Status为开始新游戏
  [gameLogic_ startNewGame];
}

- (void)tick: (ccTime) dt{	
	[gameLogic_ gameLoop];
}

#pragma mark -------------------------------------------------------------------
#pragma mark Sprite
- (void)updateCurrentCard{
  NSLog(@"updateCurrentCard");
  //删除打掉的牌
  for (CardSprite *card in cardSpriteArray_) {
    if(card.pickFlag == 1) [cardSpriteArray_ removeObject:card];
  }
  
  //重新排列
  int cardCount = [cardSpriteArray_ count];
  int offset = (CARD_AREA_WIDTH - CARD_ORIGINAL_WIDTH * CARD_SCALE) / cardCount - 1;
  if (offset > OFFSET_MAX) {
    offset = OFFSET_MAX;
  }
  
  CGPoint pointFirstCard;
  CGPoint point = LOCAL_CARD_CENTER;
  if (cardCount % 2 == 1) {
    pointFirstCard.x = point.x  - (offset * cardCount / 2);
    pointFirstCard.y = point.y;
  }else{
    pointFirstCard.x = point.x - (offset * cardCount / 2) - offset / 2;
    pointFirstCard.y = point.y;
  }
  
  
  for (CardSprite *card in cardSpriteArray_) {
    card.position = pointFirstCard;
    pointFirstCard.x = pointFirstCard.x + offset;
  }  
}

- (CardSprite*)buildCardSprite:(FZCardType)type{
  CardSprite *sprite;
  switch (type) {
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

#pragma mark -------------------------------------------------------------------
#pragma mark 按钮和菜单
- (void)resultLayerOkButtonClick{
  [resultLayer_ hideResult];
  
  //clear
  for (CCSprite *sprt in cardSpriteArray_) {
    [self removeChild:sprt cleanup:YES];
  }
  [cardSpriteArray_ removeAllObjects];
  
  for (CCSprite *sprt in cardsOnDesk_) {
    [self removeChild:sprt cleanup:YES];
  }
  [cardsOnDesk_ removeAllObjects];
  
  if (gameLogic_.gameStatus_ == FZGameStatus_RoundOver){
    [gameLogic_ startNewRound];
  }
}

- (void)menuButtonClick:(id)sender{
  self.isTouchEnabled = NO;
  menuLayer_.visible = YES;
}

- (void)playButtonClick:(id)sender{
  if([gameLogic_ localPlayerClickPlayButton]){
    //记录下现在打得是那几张牌，在UpdateUI的时候，把这俩张牌移动到中央位置
    
    //[self updateCurrentCard];
  }
}

- (void)passButtonClick:(id)sender{
  [self resetCards];
  [gameLogic_ localPlayerClickPassButton];
}

- (void)actionButtonClick:(id)sender{
  if (playOrPassFlag_ == 0) {//pass
    [self passButtonClick:nil];
  }
  else {
    [self playButtonClick:nil];
    
  }
  selectCardNum_ = 0;
}

- (void)helpActionButtonClick:(id)sender{
  if (tipsOrRestFlag_ == 0) { //tips
    [self nextTips];
  }else {
    [self resetCards];
    
    if ([gameLogic_ canPass]) {
      [self showPassButton];
    }else {
      [self hideActionMenu];
    }
    
    [helpActionButton_ setString:@"Tips"];
    tipsOrRestFlag_ = 0;    
  }
}

- (void)showPassButton{
  [actionButton_ setString:@"Pass"];
  playOrPassFlag_ = 0;
  actionMenu_.visible = YES;
}

- (void)showPlayButton{
  [actionButton_ setString:@"Play"];
  playOrPassFlag_ = 1;
  actionMenu_.visible = YES;
}

- (void)hideActionMenu{
  actionMenu_.visible = NO;
}

- (void)showTipsButton{
  [helpActionButton_ setString:@"Tips"];
  tipsOrRestFlag_ = 0;
  helpActionMenu_.visible = YES;
}

- (void)showResetButton{
  [helpActionButton_ setString:@"Reset"];
  tipsOrRestFlag_ = 1;
  helpActionMenu_.visible = YES;
}

- (void)hideHelpActionMenu{
  helpActionMenu_.visible = NO;
}

- (void)nextTips{
  [gameLogic_.localPlayer_ getNextTips];
  int playOrPassFlag = 0;
  //在cardInHand里面找到pickFlag为1的牌
  for (int i = 0; i < [cardSpriteArray_ count]; i++) {
    FZCard * card = [gameLogic_.localPlayer_.cardInHandArray_ objectAtIndex:i];
    CardSprite * cardSprite= [cardSpriteArray_ objectAtIndex:i];
    if (card.toPlayFlag) {
      playOrPassFlag = 1;
    }
    if (card.toPlayFlag == cardSprite.pickFlag){
      continue;
    }
    if (card.toPlayFlag && !cardSprite.pickFlag) {
      CGPoint moveTo = cardSprite.position;
      moveTo.y = moveTo.y + 20;
      cardSprite.position = moveTo; 
      cardSprite.pickFlag = 1;
    }
    if (!card.toPlayFlag && cardSprite.pickFlag) {
      CGPoint moveTo = cardSprite.position;
      moveTo.y = moveTo.y - 20;
      cardSprite.position = moveTo;
      cardSprite.pickFlag = 0;
    }
  }
  
  if(playOrPassFlag) [self showPlayButton];
  else [self showPassButton];
}

- (void)resetCards{
  //遍历所有牌，全部设置为没有选中  
  NSArray *cards = [gameLogic_ getLocalPlayerCards];
  for (int i = 0; i<[cardSpriteArray_ count]; i++) {
    FZCard *card = [cards objectAtIndex:i];
    CardSprite *sprite = [cardSpriteArray_ objectAtIndex:i];
    
    if(sprite.pickFlag == 1) {
      CGPoint point = sprite.position;
      point.y = point.y - 20;
      sprite.position = point;
      sprite.scale=CARD_SCALE;
      sprite.pickFlag = 0;
    }
    
    card.toPlayFlag = 0;
  }
  
}
#pragma mark -------------------------------------------------------------------
#pragma mark GameMenuDelegate Protocol delegate
- (void)GameMenuLayerResumeButtonClick{
  menuLayer_.visible = NO;
  self.isTouchEnabled = YES;
}

- (void)GameMenuLayerStartNewGameButtonClick{
  //[self clearGame];
  [self unschedule: @selector(tick:)];
  [self startNewGame];
  
  menuLayer_.visible = NO;
  self.isTouchEnabled = YES;
}

- (void)GameMenuQuitButtonClick{
  [self unschedule: @selector(tick:)];
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene node]];
}



#pragma mark -------------------------------------------------------------------
#pragma mark GameLogicUIDelegate Protocol Delegate
- (void)updateUI_initNewGame{
  [self updateUI_initNewRound];
}

- (void)updateUI_initNewRound{
  //把手中的每张牌加到画面上去
  
  //point.x = point.x + CARD_ORIGINAL_WIDTH / 2 * CARD_SCALE;
 
  NSArray *cards = [gameLogic_ getLocalPlayerCards];
  

  int cardCount = [cards count];
  int offset = (CARD_AREA_WIDTH - CARD_ORIGINAL_WIDTH * CARD_SCALE) / cardCount - 1;
  if (offset > OFFSET_MAX) {
    offset = OFFSET_MAX;
  }
  CGPoint pointFirstCard;
  CGPoint point = LOCAL_CARD_CENTER;
  if (cardCount % 2 == 1) {
    pointFirstCard.x = point.x  - (offset * cardCount / 2);
    pointFirstCard.y = point.y;
  }else{
    pointFirstCard.x = point.x - (offset * cardCount / 2) - offset / 2;
    pointFirstCard.y = point.y;
  }
  

  int zOrder =1;
  for (FZCard *card in cards) {
    CardSprite *cardSprite = [self buildCardSprite:card.cardType_];
    cardSprite.position = CARD_STACK_POSITION;
    cardSprite.scale =CARD_SCALE;
    cardSprite.pickFlag = 0;
    
    [self addChild:cardSprite z:zOrder];
    [cardSpriteArray_ addObject:cardSprite];
    
    [cardSprite runAction:[CCMoveTo actionWithDuration:0.2 position:pointFirstCard]];
  
    pointFirstCard.x = pointFirstCard.x + offset;
    zOrder++;
  }
  
  //set current player background
  currentPlayerIndex_ = gameLogic_.currentPlayerIndex_;
  if (currentPlayerIndex_ == gameConfig_.localPlayerIndex_) {
    //actionMenu_.visible = YES;
    helpActionMenu_.visible = YES;
    self.isTouchEnabled = YES;
  }else {
//    Competitor * ui = [competitorArray_ objectAtIndex: currentPlayerIndex_-1];
//    //[ui setCards:];
  }
  
  //set score
  for (int i = 1; i < PLAYER_NUMER/*gameLogic_.playerNum_*/; i++) {
    FZPlayer *p = [gameLogic_.playerArray_ objectAtIndex:i];
    Competitor * ui = [competitorArray_ objectAtIndex: i - 1];
    [ui setScore: p.roundScore_];
    [ui setTotalScore: p.gameScore_];
    [ui updateCards:[p.cardInHandArray_ count]];
  }
}

- (void)updateUI_playerStartAction{
  //计时
  if (currentPlayerIndex_ == gameConfig_.localPlayerIndex_) {
    if ([gameLogic_ canPass]) {
      [self showPassButton];

    }else {
      [self hideActionMenu];
    }
    
    [self showTipsButton];
  }
  else{
    Competitor * uiLast = [competitorArray_ objectAtIndex: currentPlayerIndex_-1];
    CGPoint point = uiLast.position_;
    point.x -= 25;
    point.y -= 25;
    timeBar_.position = point;
  }
}

#define LocalPlayerPalyedCardPostion ccp(512, 260)
- (void)updateUI_playerDoAction{  
  if (currentPlayerIndex_ == gameConfig_.localPlayerIndex_) {
    //move current to center
    CGPoint point = LocalPlayerPalyedCardPostion;
    for (CardSprite * card in cardSpriteArray_) {
      if (card.pickFlag == 1) {
        [self reorderChild:card z:[cardsOnDesk_ count]];
        
        CCAction *moveto = [CCMoveTo actionWithDuration:0.5 position:point];
        [card runAction:moveto];
        point.x += 25;
        
        
        //[cardsOnDesk_ addObject:[card retain]];
        //[cardSpriteArray_ removeObject:card];
      }
    }
    CCCallFuncN *callback = [CCCallFuncN actionWithTarget:self 
                                                 selector:@selector(updateUI_playerDoAction_Finish)];
    CCSequence *s = [CCSequence actions: [CCDelayTime actionWithDuration:0.5], callback, nil];
    [self runAction:s];
  }else{
    //Fake Thinking animatino
    float randomSleepTime = (float)((double)arc4random() / 
          ((double)ARC4RANDOM_MAX+(double)1.0) 
          * (3-1));
    
    CCAction *action = [CCScaleTo actionWithDuration:randomSleepTime 
                                              scaleX:10 * randomSleepTime / 3 
                                              scaleY:1];
    FZPlayer * player = [gameLogic_.playerArray_ objectAtIndex:currentPlayerIndex_];

    CCSequence *sequence;
    if (player.lastHand_) {
      CCCallFuncN *callback = 
      [CCCallFuncN actionWithTarget:self 
                           selector:@selector(updateUI_PlayerDoAction_Animation1)];

      sequence = [CCSequence actions: [CCDelayTime actionWithDuration:0.5], action, callback, nil];

    }else{
      CCCallFuncN *callback = 
      [CCCallFuncN actionWithTarget:self 
                           selector:@selector(updateUI_playerDoAction_Finish)];

      sequence = [CCSequence actions: [CCDelayTime actionWithDuration:0.5], action, callback, nil];
    }
      
    [timeBar_ runAction: sequence];
  }
}

#define PlayedCardOffset 25
- (void)updateUI_PlayerDoAction_Animation1{
  //animation: move card from player to center
  CCCallFuncN *callback = 
  [CCCallFuncN actionWithTarget:self 
                       selector:@selector(updateUI_playerDoAction_Finish)];

  Competitor * uiLast = [competitorArray_ objectAtIndex: currentPlayerIndex_-1];
  FZPlayer * player = [gameLogic_.playerArray_ objectAtIndex:currentPlayerIndex_];
  
  [uiLast updateCards:[player.cardInHandArray_ count]];
  
  CGPoint point = uiLast.cardSpriteCenter_;
  CGPoint center = uiLast.playedCardPosition_;
  NSArray *cards = [gameLogic_ getCurrentDeskCards].cardsArray_;
  if (cards) {
    for (FZCard *card in cards) {
      CCSprite *cardSprite = [self buildCardSprite:card.cardType_];
      
      cardSprite.position = point;
      cardSprite.scale =CARD_SCALE;
      cardSprite.rotation = uiLast.cardAngle_;
      
      [cardsOnDesk_ addObject:cardSprite];
      [self addChild:cardSprite z:[cardsOnDesk_ count]];
      
      //CCAction *moveto = [CCMoveTo actionWithDuration:0.5 position:center];
      
      CCAction * action = [CCSpawn actions:
                           [CCMoveTo actionWithDuration:0.5 position:center],
                           [CCRotateTo actionWithDuration:0.5 angle:0],nil];
      
      CCSequence *movesequence = [CCSequence actions: [CCDelayTime actionWithDuration:0], action, callback, nil];
      [cardSprite runAction:movesequence];
      
      point.x += PlayedCardOffset;
      center.x += PlayedCardOffset;
    }
    
    
  }else{
    //animation call back
    [self updateUI_playerDoAction_Finish];
  }

}

- (void)updateUI_playerDoAction_Finish{
  //int currentplayerIndex = gameLogic_.currentPlayerIndex_;
  if (currentPlayerIndex_ == 0) {
    //update cards in hand
    [self updateCurrentCard];
    selectCardNum_ = 0;
  }else{
    timeBar_.scaleX=0;
  }
  
  //update cards On Desk
//  for (CCSprite *card in cardsOnDesk_) {
//    [self removeChild:card cleanup:YES];
//  }
//  [cardsOnDesk_ removeAllObjects];
  
//  CGPoint point = CARD_STACK_POSITION;
//  
//  NSArray *cards = [gameLogic_ getCurrentDeskCards].cardsArray_;
//  if (cards) {
//    for (FZCard *card in cards) {
//      CardSprite *cardSprite = [self buildCardSprite:card.cardType_];
//      
//      cardSprite.position = point;
//      cardSprite.scale =CARD_SCALE;
//      [cardsOnDesk_ addObject:cardSprite];
//      [self addChild:cardSprite];
//
//      
//      point.x = point.x + 15;     
//    }
//  }
  
  gameLogic_.gameStatus_ = FZGameStatus_PlayerDoneAction;

}

- (void)updateUI_afterPlayerDoAction{
  //移除当前玩家的背景提示
  if (currentPlayerIndex_ == 0){
    actionMenu_.visible = NO;
    helpActionMenu_.visible = NO;
    self.isTouchEnabled = NO; 
  }else {
    //[[uiCompetitorArray_ objectAtIndex: currentPlayerIndex_ - 1] waitOthers];
  }
  
  //增加背景提示，表示是当前玩家
  currentPlayerIndex_ = gameLogic_.currentPlayerIndex_;
  if (currentPlayerIndex_ ==0) {
    actionMenu_.visible = YES;
    helpActionMenu_.visible = YES;
    self.isTouchEnabled = YES;
  }else{
    //[[uiCompetitorArray_ objectAtIndex: currentPlayerIndex_ - 1] currentDoAction];
  }
  
  gameLogic_.gameStatus_ = FZGameStatus_PlayerDoingAction;
}

- (void)updateUI_roundResult{
  [resultLayer_ drawRoundResult:gameLogic_];
  [resultLayer_ showResult];
}

- (void)updateUI_gameResult{
  
}

#pragma mark -------------------------------------------------------------------
#pragma mark Touch Events
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  //取消多点触摸
  if (touched_) {
    return;
  }

  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:[touch view]];
  point = [[CCDirector sharedDirector] convertToGL:point];
  CGPoint moveTo;

  for (int i = [cardSpriteArray_ count] - 1; i >= 0; i--) {
    currentCard_ = [cardSpriteArray_ objectAtIndex:i];
    if ((point.x > currentCard_.position.x - currentCard_.textureRect.size.width/2 * CARD_SCALE)&&
        (point.x < currentCard_.position.x + currentCard_.textureRect.size.width/2 * CARD_SCALE)&&
        (point.y > currentCard_.position.y - currentCard_.textureRect.size.height/2 * CARD_SCALE)&&
        (point.y < currentCard_.position.y + currentCard_.textureRect.size.height/2 * CARD_SCALE))
    {

      NSArray *cards = [gameLogic_ getLocalPlayerCards];
      FZCard *card = [cards objectAtIndex:i];
      NSLog(@"Click Card: %@", [card getCardName]);      
      moveTo = currentCard_.position;
      if(card.toPlayFlag == 1){
        card.toPlayFlag=0;
        moveTo.y = moveTo.y - 20;
        currentCard_.position = moveTo; 
        selectCardNum_ --;
        
        currentCard_.pickFlag = 0;
      }else {
        card.toPlayFlag=1;
        moveTo.y = moveTo.y + 20;
        currentCard_.position = moveTo; 
        selectCardNum_ ++;
        currentCard_.pickFlag = 1;
      }
      
      touched_ = YES; 
      originalPoint_=currentCard_.position;
      originalZOrder_=currentCard_.zOrder;
      NSLog(@"Before reorder");
      [self reorderChild:currentCard_ z:50];
      NSLog(@"After reorder");      
      currentCard_.scale= CARD_SCALE_LARGE;
      
      break;
    }
  }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//  if (touched_) {
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:[touch view]];
//    point = [[CCDirector sharedDirector] convertToGL:point];
//    
//    //  currentSprite_.scale = 0.1;
//    currentCard_.position = point;
//  }  
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  //_isTouchBegan = false; 
  touched_ = NO;
  currentCard_.position = originalPoint_;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
  if (touched_){
    touched_ = NO;
    currentCard_.scale = CARD_SCALE;
    currentCard_.position = originalPoint_;
    [self reorderChild:currentCard_ z:originalZOrder_];
    

    if (selectCardNum_ == 0) {
      if ([gameLogic_ canPass]) {
        [self showPassButton];
      }else {
        [self hideActionMenu];
      }
      
      [helpActionButton_ setString:@"Tips"];
      tipsOrRestFlag_ = 0;    
    }else {
      NSLog(@"before canPlay"); 
      if ([gameLogic_ canPlay]) {//[gameLogic_ canPlaySelectCards]
        [self showPlayButton];
      }else {
        [self hideActionMenu];
      } 
      NSLog(@"after canPlay"); 
      
      [helpActionButton_ setString:@"Reset"];
      tipsOrRestFlag_ = 1;
    }
    
  }
  
  
}



@end
