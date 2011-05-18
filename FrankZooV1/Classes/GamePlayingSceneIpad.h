//
//  GamePlayingSceneIpad.h
//  FrankZoo
//
//  Created by wang chenzhong on 4/18/11.
//  Copyright 2011 mclockw@tentap.com. All rights reserved.
//

#import "cocos2d.h"
#import "FZCard.h"
#import "ResultLayer.h"
#import "GameMenuLayer.h"
#import "CardSprite.h"
#import "FZGameLogic.h"

@interface GamePlayingSceneIpad : CCScene {
 
}
@end

@interface GamePlayingLayerIpad : CCLayer <GameMenuDelegate, GameLogicUIDelegate>{
  /* 游戏类型，玩家信息 */
  FZGameConfig *gameConfig_;  
  /* 游戏主要逻辑 */
  FZGameLogic *gameLogic_;    
  
  /* 游戏菜单: 退出，重新开始等... */
  CCMenu *menu_;              
  GameMenuLayer *menuLayer_;
  
  /* 游戏结果页面 */ 
  ResultLayer *resultLayer_;
  
  /* Tips or Reset Button */
  CCLabelTTF *actionButton_;
  CCMenu *actionMenu_;
  int playOrPassFlag_; //0: pass 1: play  

  /* Action (Play Or Pass) Button */
  CCLabelTTF *helpActionButton_;
  CCMenu *helpActionMenu_;
  int tipsOrRestFlag_; //0: tips  1: reset
  
  /* 当前出牌玩家前显示的时间条 */
  CCSprite * timeBar_;

  /* Array */
  NSMutableArray *cardsOnDesk_;     //存放其他玩家打出来的牌 CardSprite
  NSMutableArray *cardSpriteArray_; //存放自己手中的牌
  NSMutableArray *competitorArray_; //存放Competitor对象，对手的信息显示

  /* 手指Touch牌相关 */
  BOOL touched_;          
  CardSprite * currentCard_;//当前Touch的牌
  CGPoint originalPoint_;
  int originalZOrder_;
  
  /* 其他 */
  int selectCardNum_;      //当前选择点出的牌数量
  int currentPlayerIndex_; //在GameLayer中留一份playerIndex用来对UI进行操作
  int tipIndex;            //提示的Index
}

/* -------------------- 初始化 -------------------- */
- (id)initWithGameConfig:(FZGameConfig*)config;
- (void)arrangeUI; //布局界面元素

/* -------------------- 开始新游戏 -------------------- */
- (void)startNewGame;

/* -------------------- 按钮和菜单 -------------------- */
/* Play And Pass Button */
- (void)actionButtonClick:(id)sender;
- (void)passButtonClick:(id)sender;       //由actionButtonClick调用
- (void)playButtonClick:(id)sender;       //由actionButtonClick调用
- (void)showPassButton;
- (void)showPlayButton;
- (void)hideActionMenu;

/* Tips And Reset Button */
- (void)helpActionButtonClick:(id)sender;
- (void)nextTips;     //提示下一手可以出得牌
- (void)resetCards;   //设置所有的牌都为未点出状
- (void)showTipsButton;
- (void)showResetButton;
- (void)hideHelpActionMenu;

/* Game Menu */
- (void)menuButtonClick:(id)sender;

/* Result Layer Ok Button */
- (void)resultLayerOkButtonClick;

/* -------------------- Sprite -------------------- */
- (void)updateCurrentCard; //更新手中显示的牌
- (CardSprite*)buildCardSprite:(FZCardType)type;/* 生成Card Sprite */


@end

